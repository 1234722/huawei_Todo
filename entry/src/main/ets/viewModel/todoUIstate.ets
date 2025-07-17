import { oneDayItemList, todoItem } from "../model/TodoItem";
import { getData, saveData } from "../utils/dataStorage";
import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { getFormattedTime } from "../utils/Date";

@Observed
export class todoUIState {
  @Track totalTime: number = 0
  @Track totalCount: number = 0
  @Track itemList: todoItem[] = []
  @Track itemTable: Record<string, oneDayItemList> = {}
  @Track isLoadState: boolean = true
  @Track timer: timer = new timer()
  private static instance: todoUIState;
  private dataKey = 'todo_data';
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
      this.itemTable[item.date].totalCount += 1
      this.itemTable[item.date].totalTime += item.duration
      if (item.state) {
        this.itemTable[item.date].finishItem.push(item)
      } else {
        this.itemTable[item.date].waitItem.push(item)
      }
    } else {
      this.itemTable[item.date] = {
        totalCount: 1,
        totalTime: item.duration,
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
}

@Observed
export class timer{
  @Track focusMinutes: number = 25
  @Track remainingSeconds: number = 25 * 60
  @Track isRunning: boolean = false
  @Track timerId: number = -1
  @Track showCompletion: boolean = false
  @Track ringColor: Color = Color.Black
  private lastTickTime: number = 0
  private timeUpdateId: number = -1

  // 开始/暂停计时器
  toggleTimer() {
    if (this.isRunning) {
      // 暂停计时器
      if (this.timerId !== -1) {
        clearInterval(this.timerId)
        this.timerId = -1
      }
      this.isRunning = false
    } else {
      // 开始计时器
      if (this.showCompletion) {
        this.showCompletion = false
        this.remainingSeconds = this.focusMinutes * 60
      }

      this.isRunning = true
      this.lastTickTime = new Date().getTime()
      this.timerId = setInterval(() => {
        const now = new Date().getTime()
        const elapsed = this.lastTickTime > 0 ? Math.floor((now - this.lastTickTime)/1000) : 1
        this.remainingSeconds = Math.max(0, this.remainingSeconds - elapsed)
        this.lastTickTime = now

        // 根据剩余时间改变进度条颜色
        if (this.remainingSeconds < this.focusMinutes * 60 * 0.25) {
          this.ringColor = Color.Red
        } else if (this.remainingSeconds < this.focusMinutes * 60 * 0.5) {
          this.ringColor = Color.Orange
        }

        if (this.remainingSeconds <= 0) {
          clearInterval(this.timerId)
          this.timerId = -1
          this.isRunning = false
          this.showCompletion = true
          this.ringColor = Color.Green
        }
      }, 1000)
    }
  }

  // 重置计时器
  resetTimer() {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
    this.isRunning = false
    this.showCompletion = false
    this.remainingSeconds = this.focusMinutes * 60
    this.ringColor = Color.Blue
  }

  // 设置专注时间
  setFocusTime(minutes: number) {
    this.focusMinutes = minutes
    this.resetTimer()
  }

  clearTimer(){
    if (this.timerId !== -1) clearInterval(this.timerId)
    if (this.timeUpdateId !== -1) clearInterval(this.timeUpdateId)
  }
}