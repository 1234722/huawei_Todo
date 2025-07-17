//待办展示

import { todoItem } from '../../model/TodoItem'
import { sampleSelections } from '../../model/TodoItem'; //调用todo数据实例

@Component
export struct SelectionView {
  @State selectionList: Array<todoItem> = sampleSelections;

  build() {
    Column() {
      List({ space: 10 }) {
        ForEach(this.selectionList, (item: todoItem) => {
          ListItem() {
            SelectionItem({ selectionItem: item })
          }
        })
      }
      .edgeEffect(EdgeEffect.Spring)
      .width('100%')
      .height('100%')
      .padding({ left: 14, right: 14 })
    }
    .margin({ top: 16 })
  }
}

@Preview
@Component
struct SelectionItem {
  @Prop selectionItem: todoItem;

  build() {
    Row() {
      // 左侧内容区域
      Column() {
        Text(this.selectionItem.title)
          .fontColor(Color.White)
          .fontSize(20)
          .fontWeight(FontWeight.Medium)
          .margin({ bottom: 4 })

        Row() {
          Text(this.selectionItem.startTime)
            .fontSize(14)
            .fontColor(Color.White)

          Text(` ${this.selectionItem.duration}min`)
            .fontSize(14)
            .fontColor(Color.White)
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)


      Text('开始')
        .fontSize(18)
        .fontWeight(700)
        .fontColor(Color.White)
        .margin({ top: 7, right: 12 })
    }
    .width('100%')
    .height(70)
    .borderRadius(8)
    .backgroundColor('#539EE1')
    .padding(16)
    .alignItems(VerticalAlign.Center)
  }
}