import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { formatTime } from '../utils/DateTimeUtils';
import { todoUIState } from '../viewModel/todoUIstate';
import { ProfilePage } from './ProfilePage';
import { TodoPage } from './TodoPage';

@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @State viewModel: todoUIState = todoUIState.getInstance(AppStorage.get('Context') as Context);

  onBackPress(): boolean {
    if (this.viewModel.isRunning) {
      console.log('test')
      return true // 拦截返回键
    }
    return false // 放行返回键
  }

  aboutToAppear() {
    const context = AppStorage.get('Context') as Context
    // 注册持久化保存监听
    context.eventHub.on('onSaveEvent', () => {
      this.viewModel.saveData();
    });
    this.breakpointSystem.register();
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number, selectedIcon: Resource) {
    Column() {
      Image(selectedIcon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex? '#0A59F7' : 'rgba(0,0,0,0.60)')
      Text(title)
        .fontFamily('HarmonyHeiTi-Medium')
        .fontSize(10)
        .fontColor(this.currentIndex === targetIndex ? '#0A59F7' : 'rgba(0,0,0,0.60)')
        .textAlign(TextAlign.Center)
        .lineHeight(14)
        .fontWeight(500)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onClick(() => {
      this.currentIndex = targetIndex;
      this.tabsController.changeIndex(targetIndex);
    })
  }

  build() {
    if(this.viewModel.isRunning){
      Stack() {
        // 1. 背景图片层
        Image($r('app.media.test'))
          .objectFit(ImageFit.Cover)
          .width('100%')
          .height('100%')
          .backgroundColor('#fffffdfd')
          .borderRadius(20)
          .shadow({ radius: 10, color: Color.Gray, offsetX: 0, offsetY: 5 })

        // 倒计时显示
        Text(formatTime(this.viewModel.showSeconds))
          .fontSize(36)
          .fontWeight(FontWeight.Bold)
          .fontColor("#333")

        // 进度条
        Progress({
          value: 100 - (this.viewModel.showSeconds / (this.viewModel.focusMinutes * 60)) * 100,
          style: ProgressStyle.Ring
        })
          .width(150)
          .height(150)
          .color(this.viewModel.ringColor)
          .animation({ duration: 1000, curve: "easeOut" })
      }
      .width('100%')
      .height('100%')
      .alignContent(Alignment.Center)
    }else{
      Tabs({
        barPosition: this.currentBreakpoint === BreakpointTypeEnum.LG ?
        BarPosition.Start :
        BarPosition.End,
        controller: this.tabsController
      }) {
        TabContent() {
          TodoPage({viewModel: this.viewModel})
        }
        .tabBar(this.tabBarBuilder('待办', 0, $r("app.media.format_list_checks")))

        TabContent() {
          ProfilePage({viewModel: this.viewModel})
        }
        .tabBar(this.tabBarBuilder('我的', 1, $r("app.media.account_outline")))
      }
      .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG ? true : false)
      .divider({
        strokeWidth: 0.5,
        color: '#0D182431'
      })
      .scrollable(false)
      .backgroundColor('#F1F3F5')
      .padding({ top: '0.00vp', right: '0.00vp', bottom: '0.00vp', left: '0.00vp' })
    }
  }
}