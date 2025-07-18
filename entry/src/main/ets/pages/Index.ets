//entry/src/main/ets/pages/Index.ets
import router from '@ohos.router';
import { BreakpointSystem, BreakpointTypeEnum } from '../utils/BreakpointSystem';
import { todoUIState } from '../viewModel/todoUIstate';
import { ProfilePage } from './ProfilePage';
import { TodoPage } from './TodoPage';

@Entry
@Component
struct Index {
  @StorageProp('currentBreakpoint') currentBreakpoint: string = BreakpointTypeEnum.MD;
  // “持有者”，需要初值
  @StorageProp('timerRunning') running: boolean = false;
  @State currentIndex: number = 0;
  private tabsController: TabsController = new TabsController();
  private breakpointSystem: BreakpointSystem = new BreakpointSystem();
  @State viewModel: todoUIState =
    todoUIState.getInstance(AppStorage.get('Context') as Context);

  private timerListener: number = -1;

  /* 用于 off() 的同一个回调引用 */
  private readonly onTimerRunning = (val: boolean) => {
    this.running = val;
    if (val) {
      this.currentIndex = 0;
      this.tabsController.changeIndex(0);
    }
  };


  aboutToAppear() {
    const ctx = AppStorage.get('Context') as Context;

    ctx.eventHub.on('onSaveEvent', () => this.viewModel.saveData());
    this.breakpointSystem.register();

    /* 注册计时事件 */
    ctx.eventHub.on('TIMER_RUNNING', this.onTimerRunning);
  }

  aboutToDisappear() {
    this.breakpointSystem.unregister();
    const ctx = AppStorage.get('Context') as Context;

    /* 取消计时事件 */
    ctx.eventHub.off('TIMER_RUNNING', this.onTimerRunning);
  }

  @Builder
  tabBarBuilder(title: string, targetIndex: number, selectedIcon: Resource) {
    Column() {
      Image(selectedIcon)
        .width(24)
        .height(24)
        .fillColor(this.currentIndex === targetIndex ? '#0A59F7' : 'rgba(0,0,0,0.60)')
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

  // Index.ets 只改 build() 这一段，其余保持不变
  build() {
    if (this.running) {               // 计时中
      Stack() {
        Image($r('app.media.test'))
          .width('100%').height('100%')
          .objectFit(ImageFit.Cover)

        TodoPage({ viewModel: this.viewModel })   // 叠倒计时
      }
      .width('100%').height('100%')

    } else {                          // 平时
      Tabs({
        barPosition: this.currentBreakpoint === BreakpointTypeEnum.LG
          ? BarPosition.Start : BarPosition.End,
        controller: this.tabsController
      }) {
        /* 两个 TabContent 同前 */
      }
      .vertical(this.currentBreakpoint === BreakpointTypeEnum.LG)
      .divider({ strokeWidth: 0.5, color: '#0D182431' })
      .scrollable(false)
      .backgroundColor('#F1F3F5')
      .width('100%').height('100%')
    }
  }


}