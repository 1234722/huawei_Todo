import { todoUIState } from "../viewModel/todoUIstate"
import { TomatoTimer } from "./component/LockPhone"
@Preview
@Component
export struct TodoPage{
  @Link viewModel: todoUIState

  onBackPress(): boolean {
    console.log('test')
    if (!this.viewModel.timer.isRunning) {
      return true // 拦截返回键
    }
    return false // 放行返回键
  }

  build() {
    Column(){
      RelativeContainer(){
        Text('待办').alignRules({
          middle: { anchor: '__container__', align: HorizontalAlign.Center },
          center: {anchor: '__container__', align: VerticalAlign.Center }
        }).fontFamily('HarmonyHeiTi-Bold')
          .fontSize(25)
          .fontColor($r('app.color.white'))
          .fontWeight(500)
        Image($r('app.media.plus')).alignRules({
          center: {anchor: '__container__', align: VerticalAlign.Center },
          right: { anchor: '__container__', align: HorizontalAlign.End }
        }).padding({right: 2})
          .width(30)
          .height(30)
          .fillColor($r('app.color.white'))
          .onClick(() => {

          })
      }.width('100%')
      .height(80)
      .backgroundColor('#539EE1')
      .padding({top: 30})
      TomatoTimer({timer: this.viewModel.timer})
    }.width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.white'))
  }
}