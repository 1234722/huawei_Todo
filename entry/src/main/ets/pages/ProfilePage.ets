import { todoUIState } from "../viewModel/todoUIstate";



@Preview
@Component
export struct ProfilePage {
  @Link viewModel: todoUIState
  pageInfos: NavPathStack = new NavPathStack();
  build() {
    Navigation(this.pageInfos) {
      Column() {
        Row() {
          Image($r('app.media.todo_logo'))
            .margin({ left: 30, right: 20, bottom: 25 })
            .width(60)
            .height(60)
            .borderRadius(30)
            .objectFit(ImageFit.Cover)
          Column() {
            Text("千里之行，始于足下")
              .fontSize(18)
              .textAlign(TextAlign.Start)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .maxLines(1)
              .fontWeight(400)
              .fontColor($r('app.color.white'))
            Text("共专注" + 0 + "天")
              .fontSize(12)
              .textAlign(TextAlign.Start)
              .fontWeight(300)
              .fontColor(Color.Red)
              .margin({ top: 2 })
              .padding(4)
              .backgroundColor(Color.Orange)
              .borderRadius(10)
          }.padding({ bottom: 20 }).alignItems(HorizontalAlign.Start)
        }
        .backgroundImage($r('app.media.profile_backgroud'))
        .width('100%')
        .height(180)
        .alignItems(VerticalAlign.Center)

        // 添加导航项
        Column() {
          Button("专注记录")
            .fontSize(16)
            .fontWeight(500)
            .fontColor(Color.Black)
            .padding(10)
            .backgroundColor(Color.Grey)
            .borderRadius(10)
            .margin({ bottom: 10 })
            .onClick(() => {
              //Push the NavDestination page information specified by name onto the stack, and pass the data as param.
              this.pageInfos.pushPathByName('FocusRecord', null);
            })
          Button("专注统计")
            .fontSize(16)
            .fontWeight(500)
            .fontColor(Color.Black)
            .padding(10)
            .backgroundColor(Color.Grey)
            .borderRadius(10)
            .onClick(() => {
              this.pageInfos.pushPathByName('FocusStats', null);
            })
        }
        .width('80%')
        .margin({ top: 20 })
        .alignItems(HorizontalAlign.Center)

      }.width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .backgroundColor($r('app.color.white'))
    }
  }
}
