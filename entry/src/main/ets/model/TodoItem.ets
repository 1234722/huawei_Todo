import { featureAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';

export class todoItem{
  title: string = ''
  day: string = ''
  startTime: string = ''
  duration: string = ''
  experience: string = ''
  state: string = ''
}

export class oneDayItem{
  totalTime: number = 0
  waitItem: todoItem = new todoItem()
  finishItem: todoItem = new todoItem()
  NoDoneItem: todoItem = new todoItem()
}


let dataPreferences: preferences.Preferences | null = null;

preferences.getPreferences(AppStorage.get('context'), 'myStore', (err: BusinessError, val: preferences.Preferences) => {
  if (err) {
    console.error("Failed to get preferences. code =" + err.code + ", message =" + err.message);
    return;
  }
  dataPreferences = val;
  console.info("Succeeded in getting preferences.");
})