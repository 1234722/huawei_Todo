export function getFormattedDate(dateStamp: number): string {
  // 获取当前时间戳并转换为Date对象
  const date = new Date(dateStamp);

  // 提取并格式化年、月、日
  const year = date.getFullYear();
  const month = (date.getMonth() + 1).toString().padStart(2, '0');
  const day = date.getDate().toString().padStart(2, '0');

  // 拼接为日期字符串
  return `${year}-${month}-${day}`;
}