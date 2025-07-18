/* ---------- 基础数据类型 ---------- */
export interface DayPoint   { day:   string; value: number }
export interface MonthPoint { month: string; value: number }

/* ---------- 图表数据接口 ---------- */
export interface PieValue  { name: string; value: number }
export interface PieData   { id: string; values: PieValue[] }

export interface BarValue  { day: string; value: number }
export interface BarData   { id: string; values: BarValue[] }

export interface LineData<T> { id: string; values: T[] }

/* ---------- 图表 Spec 接口 ---------- */
export interface PieSpec {
  type: 'pie'
  outerRadius: string
  data: PieData[]
}

export interface BarSpec {
  type: 'bar'
  xField: string
  yField: string
  data: BarData[]
  axes: AxisSpec[]
  padding?: PaddingSpec
  bar?: BarShape
  barWidth?: number
  barGapInGroup?: number

  animationNormal?: AnimationNormalSpec
}

export interface LineSpec<T> {
  type: 'line'
  xField: string
  yField: string
  smooth: boolean
  data: LineData<T>[]
}

/* ---------- 辅助接口 ---------- */
export interface PaddingSpec {
  top?: number
  right?: number
  bottom?: number
  left?: number
}

type AxisOrient = 'left' | 'bottom'
export interface AxisSpec {
  orient: AxisOrient
  type?: 'band' | 'linear' | 'log' | string
  paddingInner?: number
  paddingOuter?: number
}

/* 柱子样式 */
export interface BarStyle {     // 颜色、圆角
  fill?: string
  radius?: number
}
export interface BarShape {     // VChart 里 bar.style
  style?: BarStyle
}
//柱状图的动画用的
/* ---------- 动画类型 ---------- */
export interface OpacityKeyframe {
  to: number          // 目标透明度
}

export interface ChannelEffects {
  fillOpacity?: OpacityKeyframe
}

export interface AnimationEffect {
  channel?: ChannelEffects
  easing?: string
}

export interface TimeSlice {
  delay?: number
  effects: AnimationEffect
  duration: number
}

export interface BarAnimationItem {
  loop?: boolean
  startTime?: number
  oneByOne?: number
  timeSlices: TimeSlice[]
}

/* 整体动画规范：目前只声明 bar，但可拓展 line、area… */
export interface AnimationNormalSpec {
  bar: BarAnimationItem[]
}
