//entry/src/main/ets/model/TodoItem.ets
import { featureAbility } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { preferences } from '@kit.ArkData';

export class todoItem{
  title: string = ''
  date: string = ''
  startTime: string = ''
  duration: number = 0
  experience: string = ''
  state: boolean = false
}

export class oneDayItemList{
  totalTime: number = 0
  totalCount: number = 0
  waitItem: todoItem[] = []
  finishItem: todoItem[] = []
}

export const sampleSelections: todoItem[] = [
  { title: "晨跑锻炼", date: '', startTime: "06:30", duration: 30, experience: ' ', state: false },
  { title: "项目会议", date: '', startTime: "09:00", duration: 60, experience: ' ', state: false },
  { title: "午餐休息", date: '', startTime: "12:00", duration: 45, experience: ' ', state: false }
]