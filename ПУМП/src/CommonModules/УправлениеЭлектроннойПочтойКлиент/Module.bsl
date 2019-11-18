///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

// Открывает вложенный файл электронного письма.
//
// Параметры:
//  Ссылка  - СправочникСсылка.ЭлектронноеПисьмоВходящееПрисоединенныеФайлы,
//            СправочникСсылка.ЭлектронноеПисьмоВходящееПрисоединенныеФайлы - ссылка на файл, который необходимо
//                                                                            открыть.
//
Процедура ОткрытьВложение(Ссылка, Форма, ДляРедактирования = Ложь) Экспорт

	ДанныеФайла = РаботаСФайламиКлиент.ДанныеФайла(Ссылка, Форма.УникальныйИдентификатор);
	
	Если Форма.ЗапрещенныеРасширения.НайтиПоЗначению(ДанныеФайла.Расширение) <> Неопределено Тогда
		
		ДополнительныеПараметры = Новый Структура("ДанныеФайла", ДанныеФайла);
		ДополнительныеПараметры.Вставить("ДляРедактирования", ДляРедактирования);
		
		Оповещение = Новый ОписаниеОповещения("ОткрытьФайлПослеПодтверждения", ЭтотОбъект, ДополнительныеПараметры);
		ПараметрыФормы = Новый Структура;
		ПараметрыФормы.Вставить("Ключ", "ПередОткрытиемФайла");
		ПараметрыФормы.Вставить("ИмяФайла", ДанныеФайла.ИмяФайла);
		ОткрытьФорму("ОбщаяФорма.ПредупреждениеБезопасности", ПараметрыФормы, , , , , Оповещение);
		Возврат;
		
	КонецЕсли;
	
	РаботаСФайламиКлиент.ОткрытьФайл(ДанныеФайла, ДляРедактирования);
	
КонецПроцедуры

Процедура ОткрытьФайлПослеПодтверждения(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат <> Неопределено И Результат = "Продолжить" Тогда
		РаботаСФайламиКлиент.ОткрытьФайл(ДополнительныеПараметры.ДанныеФайла, ДополнительныеПараметры.ДляРедактирования);
	КонецЕсли;
	
КонецПроцедуры

// Возвращает массив, содержащий структуры с информацией о контактах взаимодействия
// или участниках предмета взаимодействия.
// Параметры:
//  ТаблицаКонтактов - Документ.ТабличнаяЧасть - содержащая описания и ссылки на контакты взаимодействия
//                                               или участников предмета взаимодействия.
//
Функция ТаблицуКонтактовВМассив(ТаблицаКонтактов) Экспорт
	
	Результат = Новый Массив;
	Для Каждого СтрокаТаблицы Из ТаблицаКонтактов Цикл
		Контакт = ?(ТипЗнч(СтрокаТаблицы.Контакт) = Тип("Строка"), Неопределено, СтрокаТаблицы.Контакт);
		Запись = Новый Структура(
		"Адрес, Представление, Контакт", СтрокаТаблицы.Адрес, СтрокаТаблицы.Представление, Контакт);
		Результат.Добавить(Запись);
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

// Выполнить получение почты по всем доступным учетным записям.
// Параметры:
//  ЭлементСписок - ЭлементФормы - Элемент формы, который необходимо обновить, после получения писем.
//
Процедура ОтправитьЗагрузитьПочтуПользователя(УникальныйИдентификатор, Форма, ЭлементСписок = Неопределено) Экспорт

	ДлительнаяОперация =  ВзаимодействияВызовСервера.ОтправитьПолучитьПочтуПользователяВФоне(УникальныйИдентификатор);
	Если ДлительнаяОперация = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	ДополнительныеПараметры = Новый Структура;
	ДополнительныеПараметры.Вставить("ЭлементСписок", ЭлементСписок);
	ДополнительныеПараметры.Вставить("НавигационнаяСсылка", Форма.Окно.ПолучитьНавигационнуюСсылку());
	
	Если ДлительнаяОперация.Статус = "Выполнено" Тогда
		ОтправитьЗагрузитьПочтуПользователяЗавершение(ДлительнаяОперация, ДополнительныеПараметры);
	ИначеЕсли ДлительнаяОперация.Статус = "Выполняется" Тогда
		ПараметрыОжидания = ДлительныеОперацииКлиент.ПараметрыОжидания(Форма);
		ОповещениеОЗавершении = Новый ОписаниеОповещения("ОтправитьЗагрузитьПочтуПользователяЗавершение", ЭтотОбъект, ДополнительныеПараметры);
		ДлительныеОперацииКлиент.ОжидатьЗавершение(ДлительнаяОперация, ОповещениеОЗавершении, ПараметрыОжидания);
	КонецЕсли;
	
КонецПроцедуры

Процедура ОтправитьЗагрузитьПочтуПользователяЗавершение(Результат, ДополнительныеПараметры) Экспорт
	
	Если Результат = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если Результат.Статус = "Ошибка" Тогда
		ВызватьИсключение Результат.КраткоеПредставлениеОшибки;
	КонецЕсли;
	
	Если Результат.Статус = "Выполнено" Тогда
		
		Если ДополнительныеПараметры.ЭлементСписок <> Неопределено Тогда
			ДополнительныеПараметры.ЭлементСписок.Обновить();
		КонецЕсли;
		
		Заголовок = НСтр("ru = 'Отправка и получение почты'");
		РезультатВыполнения = ПолучитьИзВременногоХранилища(Результат.АдресРезультата);
		Если РезультатВыполнения.ЕстьОшибки Тогда
			ПоказатьОповещениеПользователя(Заголовок, ДополнительныеПараметры.НавигационнаяСсылка, 
				НСтр("ru = 'Не удалось выполнить все действия. Технические подробности для администратора в журнале регистрации.'"), 
				БиблиотекаКартинок.Ошибка32, СтатусОповещенияПользователя.Важное);
		Иначе	
			ПоказатьОповещениеПользователя(Заголовок, ДополнительныеПараметры.НавигационнаяСсылка,
				РезультатОтправкиПолученияПисем(РезультатВыполнения));
		КонецЕсли;
		
		Оповестить("ВыполненаОтправкаПолучениеПисем");
	КонецЕсли;
	
КонецПроцедуры

Функция РезультатОтправкиПолученияПисем(РезультатВыполнения)
	
	Если РезультатВыполнения.ПолученоПисем > 0 И РезультатВыполнения.ОтправленоПисем > 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Получено: %1, отправлено: %2'"), 
			РезультатВыполнения.ПолученоПисем, РезультатВыполнения.ОтправленоПисем);
	ИначеЕсли РезультатВыполнения.ПолученоПисем > 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Получено: %1'"), 
			РезультатВыполнения.ПолученоПисем);
	ИначеЕсли РезультатВыполнения.ПолученоПисем > 0 Тогда
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Отправлено: %1'"), 
			РезультатВыполнения.ОтправленоПисем);
	Иначе
		ТекстСообщения = НСтр("ru = 'Нет новых писем'");
	КонецЕсли;	
	Если РезультатВыполнения.ДоступноУчетныхЗаписей > 1 Тогда
		ТекстСообщения = ТекстСообщения + Символы.ПС  
			+ СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = '(учетных записей: %1)'"),
				РезультатВыполнения.ДоступноУчетныхЗаписей);
	КонецЕсли;
	
	Возврат ТекстСообщения;
	
КонецФункции

#КонецОбласти
