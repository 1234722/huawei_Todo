//D:\download\huawei_Todo-master\huawei_Todo-master\entry\src\main\ets\pages\Index.ets
import { VChart } from '@visactor/harmony-vchart'
import {
  BarData,
  BarShape,
  BarSpec, BarValue, DayPoint, LineSpec, MonthPoint,
  PaddingSpec,
  PieData, PieSpec } from '../model/DateMapInterface';
import { getFormattedDate } from '../utils/DateTimeUtils';
import { FocusRecord } from '../utils/FocusRecord'
import { todoUIState } from '../viewModel/todoUIstate';

/* ---------- 页面组件 ---------- */
@Entry
@Component
struct StatsPage {
  /* ---------- 原始记录 ---------- */
  private records: FocusRecord[] = [
    { start: Date.now(), duration: 1, giveUp: false }   // ← 毫秒级时间戳, 取当前设备时间
  ]
  @Link viewModel: todoUIState

  /* ---- 累计 / 今日指标 ---- */
  private totalCount   = this.viewModel.totalCount
  private totalMinutes = this.viewModel.totalTime
  private avgPerDay    = this.totalMinutes/this.totalCount

  private todayCount   = this.viewModel.itemTable[getFormattedDate()].totalCount
  private todayMinutes = this.viewModel.itemTable[getFormattedDate()].totalTime
  private todayGiveUp  = 0

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
    const today = new Date()
    const ONE_DAY = 24 * 60 * 60 * 1000
    const last7: BarValue[] = []

    // 保证按时间顺序从 6 天前 → 今天
    for (let i = 6; i >= 0; i--) {
      const d = new Date(today.getTime() - i * ONE_DAY)
      const key = `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`

      // 在 monthLineData 里查有没有该天的专注分钟数
      const found = this.monthLineData.find(p => p.day === key)
      last7.push({
        day: `${d.getMonth() + 1}/${d.getDate()}`,           // X 轴标签
        value: found ? found.value : i % 2 + 0.75                      // 没数据就填 0, 先填2，等会记得改回来
      })
    }

    const barData: BarData[] = [
      { id: 'byDay', values: last7 }
    ]
    const padding: PaddingSpec = { top: 16, right: 16, bottom: 24, left: 16 }
    const barShape: BarShape = {      // ← 直接用 BarShape
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


    /* --- 日线 --- */
    //￥￥￥￥￥等会这里随机数的部分全删了，给为传入数据
    // ① 对 day‑level 数据做一次 map，给 value 加随机量
    const jittered: DayPoint[] = this.monthLineData.map(
      (p): DayPoint => {
        const delta = Math.floor(Math.random() * 5)    // [0, 4]
        return { day: p.day, value: p.value + delta }     // 已标注返回类型
      }
    )
    this.monthLineSpec = {
      type: 'line',
      xField: 'day',
      yField: 'value',
      smooth: true,
      data: [
        {
          id: 'daily',
          values: jittered        // ② 用抖动后的数组
        }
      ]
    }

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
            Card({ title: '日均', value: `${this.avgPerDay}`,    sub: '分钟' }).layoutWeight(1)
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
