//entry/src/main/ets/pages/TodoPage.ets
import { todoUIState } from "../viewModel/todoUIstate"
import { TomatoTimer } from "./component/LockPhone"

@Component
export struct TodoPage {
  // 直接拿单例，不再用 @Link
  @State viewModel: todoUIState =
    todoUIState.getInstance(AppStorage.get('Context') as Context);

  onBackPress(): boolean {
    // 用 viewModel.timer 正常判定
    return !this.viewModel.timer.isRunning;
  }

  build() {
    Stack() {
      /* 底图 */
      Image($r('app.media.test'))
        .width('100%').height('100%')
        .objectFit(ImageFit.Cover)
        .opacity(0.3)

      /* 前景内容 */
      Column() {
        /* 头部栏（示例写回去） */
        RelativeContainer() {
          Text('待办')
            .alignRules({
              middle:{ anchor:'__container__', align: HorizontalAlign.Center },
              center:{ anchor:'__container__', align: VerticalAlign.Center }
            })
            .fontSize(25)
            .fontWeight(500)
            .fontColor($r('app.color.white'))

          // ➜ 右上角 plus
          Image($r('app.media.plus'))
            .alignRules({
              center:{ anchor:'__container__', align: VerticalAlign.Center },
              right:  { anchor:'__container__', align: HorizontalAlign.End }
            })
            .width(30).height(30)
            .fillColor($r('app.color.white'))
        }
        .width('100%').height(80)
        .backgroundColor('#539EE1')
        .padding({ top: 30 })

        /* 倒计时组件 */
        TomatoTimer({ timer: this.viewModel.timer })
      }
      .width('100%').height('100%')
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%').height('100%')
  }
}