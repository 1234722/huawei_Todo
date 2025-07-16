import { preferences } from "@kit.ArkData";
import { BusinessError } from "@kit.BasicServicesKit";
import { todoItem } from "../model/TodoItem";


  // 设置数据
export function saveData(key: string, result: todoItem[]) {
    let value: string = JSON.stringify(result);
    (AppStorage.get('Preferences') as preferences.Preferences).putSync(key, value);

  }

  // 获取数据
export function getData(key: string, callback: (result: todoItem[]) => void){
    (AppStorage.get('Preferences') as preferences.Preferences).get(key, 'default', (err: BusinessError, val: preferences.ValueType) => {
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
