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