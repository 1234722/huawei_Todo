//entry\src\main\ets\viewModel\todoUIstate.ets
import { oneDayItemList, todoItem } from "../model/TodoItem";
import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { toggleTimer } from "../utils/DateTimeUtils";

@Observed
export class todoUIState {
  @Track totalTime: number = 0
  @Track totalCount: number = 0
  @Track itemList: todoItem[] = []
  @Track itemTable: Record<string, oneDayItemList> = {}
  @Track isLoadState: boolean = true
  @Track timer: timer = new timer()
  private static instance: todoUIState;
  private pref: preferences.Preferences;

  static getInstance(context: Context): todoUIState {
    if (!todoUIState.instance) {
      todoUIState.instance = new todoUIState(context);
    }
    return todoUIState.instance;
  }

  constructor(context: Context) {
    this.isLoadState = false
    this.pref = preferences.getPreferencesSync(context, {
      name: 'my_preferences'
    });
    this.loadData((itemList: todoItem[]) => {
      this.itemList = itemList
      itemList.forEach((item) => {
        this.totalCount += 1
        this.totalTime += item.duration
        this.addForTable(item)
      })
      this.isLoadState = true
    })
  }

  addItem(item: todoItem) {
    this.itemList.push(item)
    this.addForTable(item)
  }

  private addForTable(item: todoItem){
    if (Object.keys(this.itemTable).includes(item.date)) {
      if (item.state) {
        this.itemTable[item.date].totalCount += 1
        this.itemTable[item.date].totalTime += item.duration
        this.itemTable[item.date].finishItem.push(item)
      } else {
        this.itemTable[item.date].waitItem.push(item)
      }
    } else {
      this.itemTable[item.date] = {
        totalCount: item.state ? 1 : 0,
        totalTime: item.state ? item.duration : 0,
        finishItem: item.state ? [item] : [],
        waitItem: item.state ? [] : [item]
      }
    }
  }

  saveData(): void {
    this.pref.putSync('itemList', JSON.stringify(this.itemList));
    this.pref.flushSync();
  }

  private loadData(callback: (result: todoItem[]) => void) {
    this.pref.get('itemList', 'default', (err: BusinessError, val: preferences.ValueType) => {
      if (err) {
        console.error("Failed to get value of 'startup'. code =" + err.code + ", message =" + err.message);
        return;
      }
      try{
        callback(JSON.parse(val as string) as todoItem[]);
      }catch (e){
        console.error("Failed to parse JSON string."+e);
      }
    })
  }

  initWithSampleData(list: todoItem[]) {
    this.itemList   = []
    this.itemTable  = {}
    this.totalCount = 0
    this.totalTime  = 0

    list.forEach(item => {
      this.itemList.push(item)
      this.totalCount += 1
      this.totalTime  += item.duration
      this.addForTable(item)
    })
  }
}

@Observed
export class timer{
  @Track focusMinutes: number = 25
  @Track showSeconds: number = 25 * 60
  @Track isRunning: boolean = false
  @Track ringColor: Color = Color.Blue

  startTimer() {
    this.isRunning = true // 设置计时器状态为暂停
    toggleTimer(this.showSeconds,(now: number) => {
      this.showSeconds = now
      if (this.showSeconds <= 0) {
        this.ringColor = Color.Green; // 设置颜色为绿色
      } else if (this.showSeconds < this.focusMinutes * 60 * 0.25) {
        this.ringColor = Color.Red; // 设置颜色为红色
      } else if (this.showSeconds < this.focusMinutes * 60 * 0.5) {
        this.ringColor = Color.Orange; // 设置颜色为橙色
      }
    },() => {
      this.isRunning = false // 设置计时器状态为暂停
      this.ringColor = Color.Green // 设置颜色为绿色
      this.showSeconds = this.focusMinutes * 60
    })
  }

  // 设置专注时间
  setFocusTime(minutes: number) {
    this.focusMinutes = minutes
    this.showSeconds = minutes * 60
  }

}
