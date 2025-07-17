//entry\src\main\ets\pages\StatsPage.ets
import { VChart } from '@visactor/harmony-vchart'
import { getFormattedDate } from '../utils/Date';
import { FocusRecord } from '../utils/FocusRecord'
import { todoUIState } from '../viewModel/todoUIstate';

/* ---------- 基础数据类型 ---------- */
interface DayPoint   { day:   string; value: number }
interface MonthPoint { month: string; value: number }

/* ---------- 图表数据接口 ---------- */
interface PieValue  { name: string; value: number }
interface PieData   { id: string; values: PieValue[] }

interface BarValue  { day: string; value: number }
interface BarData   { id: string; values: BarValue[] }

interface LineData<T> { id: string; values: T[] }

/* ---------- 图表 Spec 接口 ---------- */
interface PieSpec {
  type: 'pie'
  outerRadius: string
  data: PieData[]
}

interface BarSpec {
  type: 'bar'
  xField: string
  yField: string
  data: BarData[]
  axes: AxisSpec[]
  padding?: PaddingSpec
  bar?: BarShape
  barWidth?: number
  barGapInGroup?: number
}

interface LineSpec<T> {
  type: 'line'
  xField: string
  yField: string
  smooth: boolean
  data: LineData<T>[]
}

/* ---------- 辅助接口 ---------- */
interface PaddingSpec {
  top?: number
  right?: number
  bottom?: number
  left?: number
}

type AxisOrient = 'left' | 'bottom'
interface AxisSpec {
  orient: AxisOrient
  type?: 'band' | 'linear' | 'log' | string
  paddingInner?: number
  paddingOuter?: number
}

/* 柱子样式 */
interface BarStyle {     // 颜色、圆角
  fill?: string
  radius?: number
}
interface BarShape {     // VChart 里 bar.style
  style?: BarStyle
}

/* ---------- 页面组件 ---------- */
@Entry
@Component
struct StatsPage {
  /* ---------- 原始记录 ---------- */
  private records: FocusRecord[] = [
    { start: Date.now(), duration: 1, giveUp: false }   // ← 毫秒级时间戳, 取当前设备时间
  ]
  @State viewModel: todoUIState = todoUIState.getInstance(getContext(this))

  /* ---------- 累计 / 今日指标 ---------- */
  private totalCount   = this.viewModel.totalCount
  private totalMinutes = this.viewModel.totalTime
  private avgPerDay    = this.totalCount > 0 ? this.totalMinutes / this.totalCount : 0   // 防 0

  /* —— 今日 —— */
  private todayKey     = getFormattedDate(Date.now())
  private todayStats   = this.viewModel.itemTable[this.todayKey]   // 可能为 undefined

  private todayCount   = this.todayStats?.totalCount ?? 0
  private todayMinutes = (this.todayStats?.totalTime ?? 0)
  private todayGiveUp  = this.todayMinutes > 0 ? this.todayMinutes / this.todayCount : 0    // 也改为每次平均时间，但变量名未改

  /* ---- 图表状态 ---- */
  @State pieSpec      : PieSpec           = { type: 'pie', outerRadius: '0%', data: [] }
  @State barSpec      : BarSpec           = { type: 'bar', xField: '', yField: '', data: [], axes: [] }
  @State monthLineSpec: LineSpec<DayPoint>   = { type: 'line', xField: '', yField: '', smooth: true, data: [] }
  @State yearLineSpec : LineSpec<MonthPoint> = { type: 'line', xField: '', yField: '', smooth: true, data: [] }

  /* ---- 折线原始数据 ---- */
  private monthLineData: DayPoint[]   = []
  private yearLineData : MonthPoint[] = []

  /* ---- 生命周期 ---- */
  onPageShow() {
    this.aggregate()
    this.buildSpecs()
  }

  /* ---------- 数据聚合 ---------- */
  private aggregate() {
    const now = new Date()
    const todayKey = `${now.getFullYear()}-${now.getMonth() + 1}-${now.getDate()}`

    const dayMap   = new Map<string, number>()
    const monthMap = new Map<string, number>()

    this.records.forEach(r => {
      const d = new Date(r.start)
      const dayKey   = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
      const monthKey = `${d.getFullYear()}-${d.getMonth() + 1}`

      this.totalCount   += 1
      this.totalMinutes += r.duration

      if (dayKey === todayKey) {
        this.todayCount   += 1
        this.todayMinutes += r.duration
        if (r.giveUp) this.todayGiveUp += 1
      }

      dayMap.set(dayKey,   (dayMap.get(dayKey)   ?? 0) + r.duration)
      monthMap.set(monthKey, (monthMap.get(monthKey) ?? 0) + r.duration)
    })

    this.avgPerDay = this.totalMinutes === 0 ? 0
      : Math.round(this.totalMinutes / dayMap.size)

    /* 折线数据数组 */
    this.monthLineData = []
    dayMap.forEach((v, k) => this.monthLineData.push({ day: k, value: v }))

    this.yearLineData = []
    monthMap.forEach((v, k) => this.yearLineData.push({ month: k, value: v }))
  }

  /* ---------- 组装图表 ---------- */
  private buildSpecs() {
    /* --- 饼图 --- */
    const pieData: PieData[] = [
      {
        id: 'today',
        values: [
          { name: '专注', value: this.todayMinutes > 0 ? this.todayMinutes : 1 }
        ]
      }
    ]
    this.pieSpec = {
      type: 'pie',
      outerRadius: '80%',
      data: pieData
    }

    /* --- 最近 7 天柱图 --- */
    const today   = new Date()
    const ONE_DAY = 24 * 60 * 60 * 1000
    const last7: BarValue[] = []

    for (let i = 6; i >= 0; i--) {
      const d       = new Date(today.getTime() - i * ONE_DAY)
      const key     = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`   // 与 itemTable 的键一致
      const stat    = this.viewModel.itemTable[key]            // 可能 undefined
      const minutes = (stat?.totalTime ?? 0)               // 你存的是秒就 /60；若已是分钟可去掉 /60

      last7.push({
        day:   `${d.getMonth() + 1}/${d.getDate()}`,           // X 轴标签
        value: minutes                                          // Y 轴数值
      })
    }

    const barData: BarData[] = [
      { id: 'byDay', values: last7 }
    ]

    const barShape: BarShape = {
      style: { fill: '#7E6BEA', radius: 0 }
    }

    this.barSpec = {
      type: 'bar',
      xField: 'day',
      yField: 'value',
      data: barData,
      padding: { top: 16, right: 16, bottom: 24, left: 16 },
      axes: [
        { orient: 'left' },
        { orient: 'bottom', type: 'band', paddingInner: 0.4, paddingOuter: 0.05 }
      ],
      barWidth: 28,
      bar: barShape
    } as BarSpec



    /* --- 日线：本月每天的专注时长（分钟） --- */
    const now     = new Date()
    const year    = now.getFullYear()
    const month   = now.getMonth() + 1                           // 1‑12
    const daysInMonth = new Date(year, month, 0).getDate()       // 该月天数

    // 生成 daysInMonth 的顺序数组
    const monthPoints: DayPoint[] = []
    for (let d = 1; d <= daysInMonth; d++) {
      const key   = `${year}-${month}-${d}`                      // 与 itemTable 的键保持一致
      const stat  = this.viewModel.itemTable[key]                // 可能为 undefined
      const minutes = (stat?.totalTime ?? 0)               // 若已存分钟可去掉 /60

      monthPoints.push({
        day:   `${month}/${d}`,                                   // X 轴标签：MM/DD
        value: minutes                                            // Y 轴：当天分钟数
      })
    }

    this.monthLineData = monthPoints

    this.monthLineSpec = {
      type: 'line',
      xField: 'day',
      yField: 'value',
      smooth: true,
      data: [
        { id: 'daily', values: this.monthLineData }
      ]
    } as LineSpec<DayPoint>


    /* --- 月线 --- */
    this.yearLineSpec = {
      type: 'line',
      xField: 'month',
      yField: 'value',
      smooth: true,
      data: [ { id: 'monthly', values: this.yearLineData } ]
    }
  }

  /* ---------- UI ---------- */
  build() {
    Scroll() {
      Column() {
        Row(){
          Text("数据统计")
            .fontFamily('HarmonyHeiTi-Bold')
            .fontColor('#FFFFFF')
            .fontWeight("700")
            .fontSize("24")
        }
        .width('100%')
        .margin({ left: 16, top: 36 })

        /* 累计指标 */
        Column(){
          Text("累计专注")
            .fontFamily('HarmonyHeiTi-Bold')
            .width('100%')
            .fontSize("12")
            .margin({ left: 16, top: 8 })
            .fontColor('#866EFA')
            .fontWeight("700")
          Row() {
            Blank()
              .layoutWeight(0.7)
            Card({ title: '次数', value: `${this.totalCount}`,   sub: '' }).layoutWeight(1)
            //.margin({ left: 64, top: 4 })
            Card({ title: '时长', value: `${this.totalMinutes}`, sub: '分钟' }).layoutWeight(1)
            Card({ title: '平均', value: `${this.avgPerDay}`,    sub: '分钟' }).layoutWeight(1)
          }
        }
        .width('100%')
        .margin({ top: 12 })
        .backgroundColor(Color.White)
        .borderRadius(16)


        /* 今日指标 */
        Column() {
          Text("今日专注")
            .fontFamily('HarmonyHeiTi-Bold')
            .width('100%')
            .fontSize("12")
            .margin({ left: 16, top: 8 })
            .fontColor('#866EFA')
            .fontWeight("700")
          Row() {
            Blank()
              .layoutWeight(0.7)
            Card({ title: '次数', value: `${this.todayCount}`, sub: '' }).layoutWeight(1)
            Card({ title: '时长', value: `${this.todayMinutes}`, sub: '分钟' }).layoutWeight(1)
            Card({ title: '放弃', value: `${this.todayGiveUp}`, sub: '次数' }).layoutWeight(1)
          }
        }
        .width('100%')
        .margin({ top: 12 })
        .backgroundColor(Color.White)
        .borderRadius(16)

        /* 图表 */
        //VChart({ spec: this.pieSpec       }).width('100%').height(260).margin({ top: 16 })
        //  .borderRadius(16)
        /* 图表容器：先包一层 Stack 再裁剪，可确保圆角生效 */
        /* --- 图表容器 --- */
        Stack() {
          /* 1️⃣ 先放到一个 Row 里 */
          Column(){
            Text("周度数据")
              .fontFamily('HarmonyHeiTi-Bold')
              .width('100%')
              .fontSize("12")
              .margin({ left: 16, top: 8 })
              .fontColor('#866EFA')
              .fontWeight("700")
            Row() {
              VChart({ spec: this.barSpec })
                .width('90%')      // 只占容器 90
                .height(290)
            }
            .width('100%')
            .justifyContent(FlexAlign.Center)   // 2️⃣ 横向居中
          }

        }
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .clip(true)
        .margin({ top: 16 })

        Stack() {
          Column() {
            Text("月度数据")
              .fontFamily('HarmonyHeiTi-Bold')
              .width('100%')
              .fontSize("12")
              .margin({ left: 16, top: 8 })
              .fontColor('#866EFA')
              .fontWeight("700")
            VChart({ spec: this.monthLineSpec })
              .width('100%')
              .height(290)
          }
        }
        .backgroundColor('#FFFFFF')
        .borderRadius(16)
        .clip(true)
        .margin({ top: 16 })

      }
      .padding({ left: 12, right: 12, top: 12 , bottom:12})
      .backgroundColor("#7E6BEB")
    }
  }
}

/* ---------- 小卡片组件 ---------- */
@Component
struct Card {
  @Prop title: string
  @Prop value: string
  @Prop sub  : string

  build() {
    Column() {
      Text(this.title).fontSize(12).fontColor('#866EFA')
      Text(this.value).fontSize(28).fontWeight(FontWeight.Bold).margin({ top: 4 }).fontColor('#866EFA')
      Text(this.sub  ).fontSize(10).fontColor('#866EFA').margin({ top: 4 })
    }                 // ← 先结束 Column 的子树
    .padding(12)      // ← 再依次追加修饰器
    .borderRadius(12)
    .backgroundColor('#ffffff')
    //.shadow({ radius: 4, color: '#22000000', offsetX: 0, offsetY: 2 })
    .height(84)
  }
}
