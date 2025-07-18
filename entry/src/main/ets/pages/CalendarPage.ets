// ParentComponent.ets
import { todoUIState } from '../viewModel/todoUIstate';
import { CalendarComponent } from './component/CalendarComponent'

@Builder
export function a(){
  ParentComponent()
}

@Component
export struct ParentComponent {
  @State parentSelectedDate: Date = new Date(); // 父组件维护的选中日期状态
  @Link viewmodel:todoUIState

  private pathStack: NavPathStack = new NavPathStack();

  // 格式化日期显示
  private formatDate(date: Date): string {
    return `${date.getFullYear()}年${date.getMonth() + 1}月${date.getDate()}日`;
  }

  // 获取星期几
  private getWeekday(date: Date): string {
    const weekdays = ['星期日', '星期一', '星期二', '星期三', '星期四', '星期五', '星期六'];
    return weekdays[date.getDay()];
  }

  // 判断是否是今天
  private isToday(date: Date): boolean {
    const today = new Date();
    return date.toDateString() === today.toDateString();
  }

  build() {
    NavDestination() {
    Column() {
      // 页面标题
      Text('我的日历')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .margin({ bottom: 30 })
        .textAlign(TextAlign.Center)

      // 日历组件
      CalendarComponent({
        selectedDate: this.parentSelectedDate, // 传递选中日期
        viewModel: this.viewmodel
      })
        .margin({ bottom: 30 })

      // 选中日期信息卡片
      // Column() {
      //   // 日期信息
      //   Row() {
      //     Column() {
      //       Text(this.formatDate(this.parentSelectedDate))
      //         .fontSize(20)
      //         .fontWeight(FontWeight.Bold)
      //         .fontColor('#333')
      //         .margin({ bottom: 5 })
      //
      //       Text(this.getWeekday(this.parentSelectedDate))
      //         .fontSize(16)
      //         .fontColor('#666')
      //     }
      //     .alignItems(HorizontalAlign.Start)
      //     .layoutWeight(1)
      //
      //     // 今天标识
      //     if (this.isToday(this.parentSelectedDate)) {
      //       Text('今天')
      //         .fontSize(14)
      //         .fontColor(Color.White)
      //         .backgroundColor('#007AFF')
      //         .padding({ left: 12, right: 12, top: 6, bottom: 6 })
      //         .borderRadius(12)
      //     }
      //   }
      //   .width('100%')
      //   .alignItems(VerticalAlign.Center)
      //
      //   // 分割线
      //   Divider()
      //     .margin({ top: 15, bottom: 15 })
      //     .color('#eee')
      //
      //   // 日期详细信息
      //   Row() {
      //     Text('选中日期：')
      //       .fontSize(16)
      //       .fontColor('#666')
      //
      //     Text(this.parentSelectedDate.toLocaleDateString())
      //       .fontSize(16)
      //       .fontColor('#333')
      //       .fontWeight(FontWeight.Medium)
      //   }
      //   .width('100%')
      //   .justifyContent(FlexAlign.Start)
      // }
      // .width('100%')
      // .padding(20)
      // .backgroundColor('#fff')
      // .borderRadius(12)
      // .shadow({ radius: 8, color: '#00000010', offsetX: 0, offsetY: 2 })
      //
      // // 底部空白区域
      // Blank()
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .backgroundColor('#f5f5f5')
  }.title('专注记录')
    .onReady((context: NavDestinationContext) => {
      this.pathStack = context.pathStack; // 获取导航栈引用
    })
  }
}