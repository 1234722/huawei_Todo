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
  deleteItem(item: todoItem) {
    //使用 filter 过滤掉匹配 title 和 date 的项，并更新 itemList
    this.removeFromTable(item)
    this.itemList = this.itemList.filter(
      (waitItem) => waitItem.title !== item.title || waitItem.date !== item.date
    );
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
        dateGroup.finishItem = dateGroup.finishItem.filter(
          i => !(i.title === item.title && i.startTime === item.startTime)
        );
      } else {
        dateGroup.waitItem = dateGroup.waitItem.filter(
          i => !(i.title === item.title && i.startTime === item.startTime)
        );
      }
    }
  }
  //更新新新新新新新新新新新新新新
   immediatelyfreshTotalTime(item: todoItem): void {
    //更新tt，tc
     //removeitem从list里面删除
     this.deleteItem(item);
     this.isRunning=true;
     //启动计时器
     toggleTimer(item.duration,(now: number) => {
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
       item.state=true;
       this.addForTable(item);
       this.addItem(item);
       this.totalTime += item.duration;
       this.totalCount += 1;
     })

     //加入finish

  }
  whenadd(item: todoItem){
    this.addItem(item);
    setInterval(() => this.immediatelyfreshTotalTime(item),timeToSeconds(item.startTime)-timeToSeconds(getFormattedTime()),undefined);//创建出了定时器

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
