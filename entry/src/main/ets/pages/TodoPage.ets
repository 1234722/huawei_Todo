@Preview
@Component
export struct TodoPage{
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
    }.width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.white'))
  }
}