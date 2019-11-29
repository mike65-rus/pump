&НаСервере
Функция ПолучитьКодЭлементаНаСервере()
	пТекСтр=Элементы.Список.ТекущаяСтрока;
	Если пТекСтр=Неопределено Тогда
		Возврат "";
	КонецЕсли;
	пТекОбъект=пТекСтр.ПолучитьОбъект();
	Если пТекОбъект.ЭтоГруппа Тогда
		Возврат "";
	КонецЕсли;
	Возврат СОКРЛП(пТекОбъект.Код);
КонецФункции	
&НаКлиенте
Процедура ОткрытьСправочник(Команда)
	пКод=ПолучитьКодЭлементаНаСервере();
	Если ПустаяСтрока(пКод) Тогда
		Возврат;
	КонецЕсли;	
	Попытка
		ОткрытьФорму("Справочник."+пКод+".ФормаСписка");
	Исключение
		
	КонецПопытки;		
КонецПроцедуры
