import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';
import storage from '@ohos.data.storage';
import { preferences } from '@kit.ArkData';

const TAG: string = 'EntryAbility';


export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    this.context.eventHub.emit('onSaveEvent');
    this.context.eventHub.off('onSaveEvent');
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    requestFullScreen(windowStage, this.context);
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      let windowClass = windowStage.getMainWindowSync();
      AppStorage.setOrCreate('UIContext',windowClass.getUIContext());
      // 获取上下文并存储
      AppStorage.setOrCreate('Context', this.context)
      let options: preferences.Options = { name: 'myStore' };
      AppStorage.setOrCreate('Preferences', preferences.getPreferencesSync(this.context, options))
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}

function requestFullScreen(windowStage: window.WindowStage, context: Context): void {
  windowStage.getMainWindow((err: BusinessError, data: window.Window) => {
    if (err.code) {
      return;
    }
    let windowClass: window.Window = data;
    windowClass.setWindowLayoutFullScreen(true);
  });
}
