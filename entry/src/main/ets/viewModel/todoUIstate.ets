import { oneDayItemList, todoItem } from "../model/TodoItem";
import { getData, saveData } from "../utils/dataStorage";
import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";

@Observed
export class todoUIState {
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