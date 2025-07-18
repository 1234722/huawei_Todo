//entry\src\main\ets\viewModel\todoUIstate.ets
import { oneDayItemList, todoItem } from "../model/TodoItem";
import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { formatTime, getFormattedTime, timeToSeconds, toggleTimer } from "../utils/DateTimeUtils";

@Observed
export class todoUIState {
  @Track totalTime: number = 0
  @Track totalCount: number = 0
  @Track itemList: todoItem[] = []
  @Track itemTable: Record<string, oneDayItemList> = {}
  @Track isLoadState: boolean = true
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
        totalCount: item.state ? 1 : 0,
        totalTime: item.state ? item.duration : 0,
        finishItem: item.state ? [item] : [],
        waitItem: item.state ? [] : [item]
      }
    }
  }
  private removeFromTable(item: todoItem): void {
    if (this.itemTable[item.date]) {
      const dateGroup = this.itemTable[item.date];
      dateGroup.totalCount -= 1;
      dateGroup.totalTime -= item.duration;

      if (item.state) {
        // 从 finishItem 中移除（通过 filter 过滤匹配项）
        dateGroup.finishItem = dateGroup.finishItem.filter(
          i => !(i.title === item.title && i.startTime === item.startTime)
        );
      } else {
        // 从 waitItem 中移除
        dateGroup.waitItem = dateGroup.waitItem.filter(
          i => !(i.title === item.title && i.startTime === item.startTime)
        );
      }
      // 如果该日期的项目数为 0，则移除整个日期键（赋值为 undefined）
      if (dateGroup.totalCount === 0) {
        this.itemTable[item.date] = {
          totalCount: 0,
          totalTime: 0,
          waitItem: [],
          finishItem: []
        };
      }
    }
  }
  //更新新新新新新新新新新新新新新
   immediatelyfreshTotalTime(item: todoItem): void {
    //更新tt，tc
    this.totalTime += item.duration;
    this.totalCount += 1;
    //更新 itemTable
    this.addForTable(item)
     toggleTimer(item.duration,undefined,() => this.removeFromTable(item));//第二部分，定时器
  }
  //
   laterfreshTotalTime(item: todoItem):void{
    // 解析item中的时间（假设item.date格式为YYYY-MM-DD，item.startTime为HH:mm）
    const targetDate = new Date(`${item.date}T${item.startTime}:00`);
    const currentTime = new Date();

    // 计算时间差
    const timeDiff = targetDate.getTime() - currentTime.getTime();

    // 如果时间已过，即时执行
    if (timeDiff <= 0) {
      this.immediatelyfreshTotalTime(item);
      return;
    }
  }
  whenadd(item: todoItem){
    toggleTimer(timeToSeconds(item.startTime)-timeToSeconds(getFormattedTime()),undefined,() => this.immediatelyfreshTotalTime(item));//创建出了定时器
    formatTime(item.duration);//数据显示
    //toggleTimer(item.duration,onsecond(11),this.immediatelyfreshTotalTime(item));
    toggleTimer(item.duration);

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
