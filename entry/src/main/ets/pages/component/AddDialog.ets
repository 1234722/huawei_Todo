//弹窗
import { SliderPage } from "./Sliderpages";


@CustomDialog
export struct addDialog {
  controller: CustomDialogController
  @State eventInput: string = '';

  build() {
    Column() {
      Row() {
        // 取消按钮（左上方）
        Button() {
          Image($r("app.media.close"))
            .width(40)
            .height(40)
            .colorBlend('#ff000000')
            .padding(8)
            .backgroundColor('#ffffffff')
            //.backgroundColor(Color.Transparent)
            //.stateEffect(false) // 禁用状态效果
        }
        .onClick(() => {
          this.controller.close()
        })


        Blank()

        Text("添加待办")

        Blank()

        // 确认按钮（右上方）
        Button() {
          Image($r("app.media.check"))
            .width(40)
            .height(40)
            .colorBlend('#ff000000')
            .padding(8)
            .backgroundColor('#ffffffff')
        }
        .onClick(() => {
          this.controller.close()
        })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Blank()

      // 输入框
      TextInput({ text: this.eventInput, placeholder: '请输入事项名称'})
        .onChange((value: string) => {
          this.eventInput = value
        })
        .margin({top: 20})

      SliderPage()

    }
    .padding(10)  // 添加一些内边距
  }
}