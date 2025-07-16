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
      Column() {
        Text('进入深度专注模式（名字待定）')
          .fontSize(18)
          .fontColor('#333')
          .margin({ bottom: 10 })
        Text('点此进入锁机模式，开始专注')
          .fontSize(14)
          .fontColor('#666')
      }
      .width('100%')
      .padding(20)
      .backgroundColor('#ff4f6394')
      .shadow({ radius: 8, color: '#1A000000' }) // 阴影效果
      .margin({ top: 0 })

    }.width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.white'))
  }
}