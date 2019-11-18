///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

#Область ПрограммныйИнтерфейс

#Область ДляВызоваИзДругихПодсистем

// СтандартныеПодсистемы.УправлениеДоступом

// См. УправлениеДоступомПереопределяемый.ПриЗаполненииСписковСОграничениемДоступа.
Процедура ПриЗаполненииОграниченияДоступа(Ограничение) Экспорт
	
	Ограничение.Текст =
	"ПрисоединитьДополнительныеТаблицы
	|ЭтотСписок КАК НастройкиВариантовОтчетов
	|
	|ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставыГруппПользователей КАК СоставыГруппПользователей
	|ПО
	|	СоставыГруппПользователей.ГруппаПользователей = НастройкиВариантовОтчетов.Пользователь
	|;
	|РазрешитьЧтениеИзменение
	|ГДЕ
	|	ЭтоАвторизованныйПользователь(Пользователь, НЕОПРЕДЕЛЕНО КАК ИСТИНА)
	|	ИЛИ ЭтоАвторизованныйПользователь(СоставыГруппПользователей.Пользователь)
	|	ИЛИ ЭтоАвторизованныйПользователь(Вариант.Автор)";
	
	Ограничение.ТекстДляВнешнихПользователей = Ограничение.Текст;
	
КонецПроцедуры

// Конец СтандартныеПодсистемы.УправлениеДоступом

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Записывает таблицу настроек в данные регистра по указанным измерениям.
Процедура ЗаписатьПакетНастроек(ТаблицаНастроек, Измерения, Ресурсы, УдалятьСтарые) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	Для Каждого КлючИЗначение Из Измерения Цикл
		НаборЗаписей.Отбор[КлючИЗначение.Ключ].Установить(КлючИЗначение.Значение, Истина);
		ТаблицаНастроек.Колонки.Добавить(КлючИЗначение.Ключ);
		ТаблицаНастроек.ЗаполнитьЗначения(КлючИЗначение.Значение, КлючИЗначение.Ключ);
	КонецЦикла;
	Для Каждого КлючИЗначение Из Ресурсы Цикл
		ТаблицаНастроек.Колонки.Добавить(КлючИЗначение.Ключ);
		ТаблицаНастроек.ЗаполнитьЗначения(КлючИЗначение.Значение, КлючИЗначение.Ключ);
	КонецЦикла;
	Если Не УдалятьСтарые Тогда
		НаборЗаписей.Прочитать();
		СтарыеЗаписи = НаборЗаписей.Выгрузить();
		ПоискПоИзмерениям = Новый Структура("Пользователь, Подсистема, Вариант");
		Для Каждого СтараяЗапись Из СтарыеЗаписи Цикл
			ЗаполнитьЗначенияСвойств(ПоискПоИзмерениям, СтараяЗапись);
			Если ТаблицаНастроек.НайтиСтроки(ПоискПоИзмерениям).Количество() = 0 Тогда
				ЗаполнитьЗначенияСвойств(ТаблицаНастроек.Добавить(), СтараяЗапись);
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	НаборЗаписей.Загрузить(ТаблицаНастроек);
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

// Очищает настройки по варианту отчета.
Процедура СброситьНастройки(ВариантСсылка = Неопределено) Экспорт
	
	НаборЗаписей = СоздатьНаборЗаписей();
	Если ВариантСсылка <> Неопределено Тогда
		НаборЗаписей.Отбор.Вариант.Установить(ВариантСсылка, Истина);
	КонецЕсли;
	НаборЗаписей.Записать(Истина);
	
КонецПроцедуры

// Очищает настройки указанного (или текущего) пользователя в разделе.
Процедура СброситьНастройкиПользователяВРазделе(РазделСсылка, Пользователь = Неопределено) Экспорт
	Если Пользователь = Неопределено Тогда
		Пользователь = Пользователи.АвторизованныйПользователь();
	КонецЕсли;
	
	Запрос = Новый Запрос;
	Запрос.УстановитьПараметр("РазделСсылка", РазделСсылка);
	Запрос.Текст =
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	ИдентификаторыОбъектовМетаданных.Ссылка
	|ИЗ
	|	Справочник.ИдентификаторыОбъектовМетаданных КАК ИдентификаторыОбъектовМетаданных
	|ГДЕ
	|	ИдентификаторыОбъектовМетаданных.Ссылка В ИЕРАРХИИ(&РазделСсылка)";
	МассивПодсистем = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Ссылка");
	
	НаборЗаписей = СоздатьНаборЗаписей();
	НаборЗаписей.Отбор.Пользователь.Установить(Пользователь, Истина);
	Для Каждого ПодсистемаСсылка Из МассивПодсистем Цикл
		НаборЗаписей.Отбор.Подсистема.Установить(ПодсистемаСсылка, Истина);
		НаборЗаписей.Записать(Истина);
	КонецЦикла;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Обработчики чтения / записи настроек доступности варианта отчета.

Процедура ПрочитатьНастройкиДоступностиВариантаОтчета(ВариантОтчета, ПользователиВарианта,
	ИспользоватьГруппыПользователей = Неопределено, ИспользоватьВнешнихПользователей = Неопределено) Экспорт 
	
	Если Не ПравоДоступа("Чтение", Метаданные.Справочники.Пользователи) Тогда 
		Возврат;
	КонецЕсли;
	
	ПользователиВарианта.Очистить();
	
	ИспользоватьГруппыПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьГруппыПользователей");
	ИспользоватьВнешнихПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей");
	
	#Область ЗапросПользователейВарианта
	
	// АПК:96-вкл При получении результата объединения второго и третьего запросов, в результат могут попасть неуникальные записи.
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ
	|	ИСТИНА КАК Пометка,
	|	Настройки.Пользователь КАК Значение,
	|	ПРЕДСТАВЛЕНИЕ(Настройки.Пользователь) КАК Представление,
	|	ВЫБОР
	|		КОГДА ТИПЗНАЧЕНИЯ(Настройки.Пользователь) = ТИП(Справочник.Пользователи)
	|			ТОГДА ""СостояниеПользователя02""
	|		КОГДА ТИПЗНАЧЕНИЯ(Настройки.Пользователь) = ТИП(Справочник.ГруппыВнешнихПользователей)
	|			ТОГДА ""СостояниеПользователя10""
	|		ИНАЧЕ ""СостояниеПользователя04""
	|	КОНЕЦ КАК Картинка,
	|	ИСТИНА В (
	|			ВЫБРАТЬ ПЕРВЫЕ 1
	|				ИСТИНА
	|			ИЗ
	|				РегистрСведений.СоставыГруппПользователей КАК СоставыГруппПользователей
	|			ГДЕ
	|				СоставыГруппПользователей.Пользователь = &ТекущийПользователь
	|				И СоставыГруппПользователей.ГруппаПользователей = Настройки.Пользователь
	|				И НЕ СоставыГруппПользователей.ГруппаПользователей В (
	|					ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.ВсеПользователи),
	|					ЗНАЧЕНИЕ(Справочник.ГруппыВнешнихПользователей.ВсеВнешниеПользователи))
	|		) КАК ЭтоТекущийПользователь
	|ИЗ
	|	РегистрСведений.НастройкиВариантовОтчетов КАК Настройки
	|ГДЕ
	|	(&ИспользоватьГруппыПользователей
	|		ИЛИ &ИспользоватьВнешнихПользователей)
	|	И Настройки.Вариант = &ВариантОтчета
	|	И ТИПЗНАЧЕНИЯ(Настройки.Пользователь) <> ТИП(Справочник.ВнешниеПользователи)
	|	И Настройки.Подсистема = ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)
	|	И Настройки.Видимость
	|
	|ОБЪЕДИНИТЬ ВСЕ
	|
	|ВЫБРАТЬ
	|	ВЫБОР
	|		КОГДА &ВариантОтчета В (НЕОПРЕДЕЛЕНО, ЗНАЧЕНИЕ(Справочник.ВариантыОтчетов.ПустаяСсылка))
	|		ТОГДА Пользователи.Ссылка = &ТекущийПользователь
	|		ИНАЧЕ НЕ Настройки.Вариант ЕСТЬ NULL
	|	КОНЕЦ КАК Пометка,
	|	Пользователи.Ссылка КАК Значение,
	|	ПРЕДСТАВЛЕНИЕ(Пользователи.Ссылка) КАК Представление,
	|	""СостояниеПользователя02"" КАК Картинка,
	|	Пользователи.Ссылка = &ТекущийПользователь КАК ЭтоТекущийПользователь
	|ИЗ
	|	Справочник.Пользователи КАК Пользователи
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиВариантовОтчетов КАК Настройки
	|		ПО Настройки.Вариант = &ВариантОтчета
	|		И Настройки.Пользователь В (Пользователи.Ссылка, НЕОПРЕДЕЛЕНО)
	|		И Настройки.Подсистема = ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)
	|		И Настройки.Видимость
	|ГДЕ
	|	НЕ &ИспользоватьГруппыПользователей
	|	И НЕ &ИспользоватьВнешнихПользователей
	|	И НЕ Пользователи.ПометкаУдаления
	|	И НЕ Пользователи.Недействителен
	|	И НЕ Пользователи.Служебный
	|
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	Пользователи.Ссылка КАК Значение,
	|	ПРЕДСТАВЛЕНИЕ(Пользователи.Ссылка) КАК Представление,
	|	""СостояниеПользователя02"" КАК Картинка,
	|	Пользователи.Ссылка = &ТекущийПользователь КАК ЭтоТекущийПользователь
	|ИЗ
	|	РегистрСведений.НастройкиВариантовОтчетов КАК Настройки
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГруппыПользователей КАК ГруппыПользователей
	|		ПО ГруппыПользователей.Ссылка = Настройки.Пользователь
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ГруппыПользователей.Состав КАК СоставыГруппПользователей
	|		ПО СоставыГруппПользователей.Ссылка = ГруппыПользователей.Ссылка
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО Пользователи.Ссылка = СоставыГруппПользователей.Пользователь
	|ГДЕ
	|	НЕ &ИспользоватьГруппыПользователей
	|	И НЕ &ИспользоватьВнешнихПользователей
	|	И Настройки.Вариант = &ВариантОтчета
	|	И Настройки.Подсистема = ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)
	|	И Настройки.Видимость
	|	И НЕ ГруппыПользователей.ПометкаУдаления
	|	И НЕ Пользователи.ПометкаУдаления
	|	И НЕ Пользователи.Недействителен
	|	И НЕ Пользователи.Служебный
	|	
	|ОБЪЕДИНИТЬ
	|
	|ВЫБРАТЬ
	|	ИСТИНА КАК Пометка,
	|	&ТекущийПользователь КАК Значение,
	|	ПРЕДСТАВЛЕНИЕ(&ТекущийПользователь) КАК Представление,
	|	""СостояниеПользователя02"" КАК Картинка,
	|	ИСТИНА КАК ЭтоТекущийПользователь
	|ГДЕ
	|	&ВариантОтчета В (НЕОПРЕДЕЛЕНО, ЗНАЧЕНИЕ(Справочник.ВариантыОтчетов.ПустаяСсылка))");
	
	Запрос.УстановитьПараметр("ВариантОтчета", ВариантОтчета);
	Запрос.УстановитьПараметр("ИспользоватьГруппыПользователей", ИспользоватьГруппыПользователей);
	Запрос.УстановитьПараметр("ИспользоватьВнешнихПользователей", ИспользоватьВнешнихПользователей);
	Запрос.УстановитьПараметр("ТекущийПользователь", Пользователи.АвторизованныйПользователь());
	
	// АПК:96-выкл При получении результата объединения второго и третьего запросов, в результат могут попасть неуникальные записи.
	
	#КонецОбласти
	
	Выборка = Запрос.Выполнить().Выбрать();
	
	Если Выборка.НайтиСледующий(Неопределено, "Значение") Тогда 
		
		ПользователиВарианта.Добавить(,, Истина, БиблиотекаКартинок.СостояниеПользователя04);
		Возврат;
		
	КонецЕсли;
	
	Выборка.Сбросить();
	
	Пока Выборка.Следующий() Цикл 
		
		ЭлементСписка = ПользователиВарианта.Добавить();
		ЗаполнитьЗначенияСвойств(ЭлементСписка, Выборка,, "Картинка");
		ЭлементСписка.Картинка = БиблиотекаКартинок[Выборка.Картинка];
		
		Если Выборка.ЭтоТекущийПользователь Тогда 
			ЭлементСписка.Представление = ЭлементСписка.Представление + " [ЭтоТекущийПользователь]";
		КонецЕсли;
		
	КонецЦикла;
	
	ПользователиВарианта.СортироватьПоЗначению();
	
КонецПроцедуры

Процедура ЗаписатьНастройкиДоступностиВариантаОтчета(ВариантОтчета, ЭтоНовыйВариантОтчета, ПользователиВарианта = Неопределено,
	ИспользоватьГруппыПользователей = Неопределено, ИспользоватьВнешнихПользователей = Неопределено) Экспорт 
	
	Если ПользователиВарианта = Неопределено Тогда 
		ПользователиВарианта = ПользователиВариантаОтчетаПоУмолчанию(ВариантОтчета);
	КонецЕсли;
	
	Если ТипЗнч(ПользователиВарианта) <> Тип("СписокЗначений") Тогда
		Возврат;
	КонецЕсли;
	
	НачатьТранзакцию();
	
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		
		Если Не ЭтоНовыйВариантОтчета Тогда
			
			ЭлементБлокировки = Блокировка.Добавить(Метаданные.РегистрыСведений.НастройкиВариантовОтчетов.ПолноеИмя());
			ЭлементБлокировки.УстановитьЗначение("Вариант", ВариантОтчета);
			
		КонецЕсли;
		
		Блокировка.Заблокировать();
		
		ДобавитьПользователейВариантаОтчета(
			ВариантОтчета, ПользователиВарианта, ИспользоватьГруппыПользователей, ИспользоватьВнешнихПользователей);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

Функция ПользователиВариантаОтчетаПоУмолчанию(ВариантОтчета)
	
	Если НастройкиДоступностиВариантаОтчетаУстановлены(ВариантОтчета) Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	НЕОПРЕДЕЛЕНО КАК Пользователь
	|ИЗ
	|	Справочник.ВариантыОтчетов КАК Отчеты
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыОтчетов.Размещение КАК РазмещениеОтчетов
	|		ПО РазмещениеОтчетов.Ссылка = Отчеты.Ссылка
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетов КАК ОтчетыКонфигурации
	|		ПО ОтчетыКонфигурации.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетов.Размещение КАК РазмещениеОтчетовКонфигурации
	|		ПО РазмещениеОтчетовКонфигурации.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетовРасширений КАК ОтчетыРасширений
	|		ПО ОтчетыРасширений.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетовРасширений.Размещение КАК РазмещениеОтчетовРасширений
	|		ПО РазмещениеОтчетовРасширений.Ссылка = Отчеты.ПредопределенныйВариант
	|ГДЕ
	|	Отчеты.Ссылка = &ВариантОтчета
	|	И ЕСТЬNULL(РазмещениеОтчетов.Использование, ИСТИНА) 
	|	И НЕ ЕСТЬNULL(РазмещениеОтчетов.Подсистема,
	|		ЕСТЬNULL(РазмещениеОтчетовКонфигурации.Подсистема, РазмещениеОтчетовРасширений.Подсистема)) ЕСТЬ NULL
	|	И ЕСТЬNULL(ОтчетыКонфигурации.ВидимостьПоУмолчанию, ОтчетыРасширений.ВидимостьПоУмолчанию) = ИСТИНА");
	
	Запрос.УстановитьПараметр("ВариантОтчета", ВариантОтчета);
	
	Если Запрос.Выполнить().Пустой() Тогда 
		Возврат Неопределено;
	КонецЕсли;
	
	ПользователиВарианта = Новый СписокЗначений;
	ПользователиВарианта.ТипЗначения = Новый ОписаниеТипов(
		"СправочникСсылка.ГруппыВнешнихПользователей, СправочникСсылка.ГруппыПользователей, СправочникСсылка.Пользователи");
	
	ПользователиВарианта.Добавить(,, Истина);
	
	Возврат ПользователиВарианта;
	
КонецФункции

Функция НастройкиДоступностиВариантаОтчетаУстановлены(ВариантОтчета)
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ ПЕРВЫЕ 1
	|	ИСТИНА
	|ИЗ
	|	РегистрСведений.НастройкиВариантовОтчетов
	|ГДЕ
	|	Вариант = &ВариантОтчета
	|	И Подсистема = ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)");
	
	Запрос.УстановитьПараметр("ВариантОтчета", ВариантОтчета);
	
	Возврат Не Запрос.Выполнить().Пустой();
	
КонецФункции

Процедура ДобавитьПользователейВариантаОтчета(ВариантОтчета, ПользователиВарианта, ИспользоватьГруппыПользователей, ИспользоватьВнешнихПользователей)
	
	Записи = РегистрыСведений.НастройкиВариантовОтчетов.СоздатьНаборЗаписей();
	
	Подсистема = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	
	ВключитьБизнесЛогику = Не ОбновлениеИнформационнойБазы.ВыполняетсяОбновлениеИнформационнойБазы();
	
	Записи.Отбор.Вариант.Установить(ВариантОтчета);
	Записи.Отбор.Подсистема.Установить(Подсистема);
	
	ОбщиеГруппыПользователей = Новый Массив;
	ОбщиеГруппыПользователей.Добавить(Справочники.ГруппыПользователей.ВсеПользователи);
	ОбщиеГруппыПользователей.Добавить(Справочники.ГруппыВнешнихПользователей.ВсеВнешниеПользователи);
	
	Если ПользователиВарианта.НайтиПоЗначению(Неопределено) <> Неопределено
		Или ПользователиВарианта.Количество() = 1
			И ОбщиеГруппыПользователей.Найти(ПользователиВарианта[0].Значение) <> Неопределено Тогда 
		
		Запись = Записи.Добавить();
		Запись.Вариант = ВариантОтчета;
		Запись.Подсистема = Подсистема;
		Запись.Видимость = Истина;
		
		ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(Записи,,, ВключитьБизнесЛогику);
		Возврат;
		
	КонецЕсли;
	
	ВыбранныеПользователи = ВыбранныеПользователиВариантаОтчета(
		ПользователиВарианта, ИспользоватьГруппыПользователей, ИспользоватьВнешнихПользователей);
	
	Для Каждого Пользователь Из ВыбранныеПользователи Цикл 
		
		Запись = Записи.Добавить();
		Запись.Вариант = ВариантОтчета;
		Запись.Пользователь = Пользователь;
		Запись.Подсистема = Подсистема;
		Запись.Видимость = Истина;
		
	КонецЦикла;
	
	ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(Записи,,, ВключитьБизнесЛогику);
	
КонецПроцедуры

Функция ВыбранныеПользователиВариантаОтчета(ПользователиВарианта, ИспользоватьГруппыПользователей, ИспользоватьВнешнихПользователей)
	
	Если ИспользоватьГруппыПользователей = Неопределено Тогда 
		ИспользоватьГруппыПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьГруппыПользователей");
	КонецЕсли;
	
	Если ИспользоватьВнешнихПользователей = Неопределено Тогда 
		ИспользоватьВнешнихПользователей = ПолучитьФункциональнуюОпцию("ИспользоватьВнешнихПользователей");
	КонецЕсли;
	
	Если ИспользоватьГруппыПользователей
		Или ИспользоватьВнешнихПользователей Тогда 
		
		Возврат ПользователиВарианта.ВыгрузитьЗначения();
		
	КонецЕсли;
	
	ВыбранныеПользователи = Новый Массив;
	
	Для Каждого ЭлементСписка Из ПользователиВарианта Цикл 
		
		Если ЭлементСписка.Пометка Тогда 
			ВыбранныеПользователи.Добавить(ЭлементСписка.Значение);
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат ВыбранныеПользователи;
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики оповещения пользователей варианта отчета.

Процедура ЗаписатьПользователиВариантаОтчетаДоИзменения(Записи) Экспорт 
	
	// Проверка возможности записи (кэширования) состояния настроек доступности варианта отчета до записи в регистр.
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения") Тогда
		Возврат;
	КонецЕсли;
	
	МодульОбсужденияСлужебный = ОбщегоНазначения.ОбщийМодуль("ОбсужденияСлужебный");
	
	Если Не МодульОбсужденияСлужебный.Подключены()
		Или Записи.Количество() = 0 Тогда 
		
		Возврат;
	КонецЕсли;
	
	ЭлементОтбора = Записи.Отбор.Найти("Подсистема");
	Если ЭлементОтбора = Неопределено
		Или ЭлементОтбора.Значение <> Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка() Тогда 
		
		Возврат;
	КонецЕсли;
	
	ЭлементОтбора = Записи.Отбор.Найти("Вариант");
	Если ЭлементОтбора = Неопределено Тогда 
		Возврат;
	КонецЕсли;
	
	// Запись (кэширование) состояния настроек доступности варианта отчета до записи в регистр.
	УстановитьПривилегированныйРежим(Истина);
	
	ПользователиВариантаОтчета = ПользователиВариантаОтчета(ЭлементОтбора.Значение);
	ПользователиВариантаОтчетаПроиндексированные = Новый Соответствие;
	
	Пока ПользователиВариантаОтчета.Следующий() Цикл 
		
		ПользователиВариантаОтчетаПроиндексированные.Вставить(
			ПользователиВариантаОтчета.Идентификатор, ПользователиВариантаОтчета.Ссылка);
		
	КонецЦикла;
	
	Записи.ДополнительныеСвойства.Вставить(
		"ПользователиВариантаОтчетаДоИзменения", ПользователиВариантаОтчетаПроиндексированные);
	
КонецПроцедуры

Процедура ОповеститьПользователейВариантаОтчета(Записи) Экспорт 
	
	#Область Проверка
	
	Если Не ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.Обсуждения") Тогда
		Возврат;
	КонецЕсли;
	
	МодульОбсужденияСлужебный = ОбщегоНазначения.ОбщийМодуль("ОбсужденияСлужебный");
	
	УстановитьПривилегированныйРежим(Истина);
	
	ПользователиВариантаОтчетаДоИзменения = ОбщегоНазначенияКлиентСервер.СвойствоСтруктуры(
		Записи.ДополнительныеСвойства, "ПользователиВариантаОтчетаДоИзменения");
	
	Если ТипЗнч(ПользователиВариантаОтчетаДоИзменения) <> Тип("Соответствие") Тогда 
		Возврат;
	КонецЕсли;
	
	#КонецОбласти
	
	#Область АнализСостоянияНастроекДоступностиВариантаОтчета
	
	Получатели = Новый Массив;
	
	ЭлементОтбора = Записи.Отбор.Найти("Вариант");
	ПользователиВарианта = ПользователиВариантаОтчета(ЭлементОтбора.Значение);
	
	Пока ПользователиВарианта.Следующий() Цикл 
		
		Если ПользователиВариантаОтчетаДоИзменения[ПользователиВарианта.Идентификатор] <> Неопределено Тогда 
			Продолжить;
		КонецЕсли;
		
		Попытка
			ИдентификаторПользователя = СистемаВзаимодействия.ПолучитьИдентификаторПользователя(
				ПользователиВарианта.Идентификатор);
		Исключение
			Продолжить;
		КонецПопытки;
		
		Получатели.Добавить(ИдентификаторПользователя);
		
	КонецЦикла;
	
	Если Получатели.Количество() = 0 Тогда 
		Возврат;
	КонецЕсли;
	
	#КонецОбласти
	
	#Область ГенерацияОповещенияНовыхПользователейВариантаОтчета
	
	ВариантОтчета = Записи[0].Вариант;
	ПредставлениеВариантаОтчета = Строка(ВариантОтчета);
	
	ЗаголовокОбсуждения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Доступ к отчету ""%1""'"), ПредставлениеВариантаОтчета);
	
	Обсуждение = МодульОбсужденияСлужебный.ОбсуждениеКонтекстное(ВариантОтчета, ЗаголовокОбсуждения);
	
	Если СистемаВзаимодействия.ПолучитьРежимНаблюдения(Обсуждение.Идентификатор) Тогда 
		СистемаВзаимодействия.УстановитьРежимНаблюдения(Обсуждение.Идентификатор, Ложь);
	КонецЕсли;
	
	Сообщение = СистемаВзаимодействия.СоздатьСообщение(Обсуждение.Идентификатор);
	
	Для Каждого Получатель Из Получатели Цикл 
		Сообщение.Получатели.Добавить(Получатель);
	КонецЦикла;
	
	Сообщение.Автор = СистемаВзаимодействия.ИдентификаторТекущегоПользователя();
	Сообщение.Текст = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
		НСтр("ru = 'Предоставлен отчет %1'"), ПолучитьНавигационнуюСсылку(ВариантОтчета));
	
	Попытка
		Сообщение.Записать();
	Исключение
		
		КодОсновногоЯзыка = ОбщегоНазначения.КодОсновногоЯзыка();
		
		ЗаписьЖурналаРегистрации(
			НСтр("ru = 'Варианты отчетов.Оповещение о предоставлении доступа к варианту отчета'", КодОсновногоЯзыка),
			УровеньЖурналаРегистрации.Ошибка,,
			ПредставлениеВариантаОтчета,
			ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		
	КонецПопытки;
	
	#КонецОбласти
	
КонецПроцедуры

Функция ПользователиВариантаОтчета(ВариантОтчета, ВыбранныеПользователи = Неопределено) Экспорт 
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	Составы.Пользователь КАК Ссылка,
	|	Пользователи.ИдентификаторПользователяИБ КАК Идентификатор
	|ИЗ
	|	РегистрСведений.НастройкиВариантовОтчетов КАК Настройки
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.СоставыГруппПользователей КАК Составы
	|		ПО Составы.ГруппаПользователей = Настройки.Пользователь
	|		ИЛИ Настройки.Пользователь = НЕОПРЕДЕЛЕНО
	|			И Составы.ГруппаПользователей = ЗНАЧЕНИЕ(Справочник.ГруппыПользователей.ВсеПользователи)
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.Пользователи КАК Пользователи
	|		ПО Пользователи.Ссылка = Составы.Пользователь
	|ГДЕ
	|	Настройки.Вариант = &ВариантОтчета
	|	И Настройки.Подсистема = ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка)
	|	И НЕ ТИПЗНАЧЕНИЯ(Настройки.Пользователь) В (
	|		ТИП(Справочник.ВнешниеПользователи),
	|		ТИП(Справочник.ГруппыВнешнихПользователей))
	|	И Настройки.Видимость
	|	И Составы.Используется
	|	И Пользователи.Ссылка <> &ТекущийПользователь
	|	И (НЕ &ПользователиВыбраны
	|		ИЛИ Пользователи.Ссылка В (&ВыбранныеПользователи))
	|	И НЕ Пользователи.Служебный");
	
	Запрос.УстановитьПараметр("ВариантОтчета", ВариантОтчета);
	Запрос.УстановитьПараметр("ТекущийПользователь", Пользователи.АвторизованныйПользователь());
	Запрос.УстановитьПараметр("ПользователиВыбраны", ВыбранныеПользователи <> Неопределено);
	Запрос.УстановитьПараметр("ВыбранныеПользователи", ВыбранныеПользователи);
	
	Возврат Запрос.Выполнить().Выбрать();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Обработчики обновления.

// Регистрирует данные к обновлению в плане обмена ОбновлениеИнформационнойБазы
//  см. Стандарты и методики разработки прикладных решений: Параллельный режим отложенного обновления.
//
// Параметры:
//  Параметры - Структура - см. ОбновлениеИнформационнойБазы.ОсновныеПараметрыОтметкиКОбработке.
//
Процедура ЗарегистрироватьДанныеКОбработкеДляПереходаНаНовуюВерсию(Параметры) Экспорт 
	
	Запрос = Новый Запрос(
	"ВЫБРАТЬ РАЗРЕШЕННЫЕ РАЗЛИЧНЫЕ
	|	Отчеты.Ссылка КАК Вариант,
	|	ЗНАЧЕНИЕ(Справочник.ИдентификаторыОбъектовМетаданных.ПустаяСсылка) КАК Подсистема,
	|	НЕОПРЕДЕЛЕНО КАК Пользователь,
	|	ВЫБОР
	|		КОГДА Отчеты.ВидимостьПоУмолчаниюПереопределена
	|			ИЛИ ЕСТЬNULL(ОтчетыКонфигурации.ВидимостьПоУмолчанию, ОтчетыРасширений.ВидимостьПоУмолчанию) ЕСТЬ NULL
	|		ТОГДА Отчеты.ВидимостьПоУмолчанию
	|		ИНАЧЕ ЕСТЬNULL(ОтчетыКонфигурации.ВидимостьПоУмолчанию, ОтчетыРасширений.ВидимостьПоУмолчанию)
	|	КОНЕЦ КАК Видимость,
	|	ЛОЖЬ КАК БыстрыйДоступ
	|ПОМЕСТИТЬ Настройки
	|ИЗ
	|	Справочник.ВариантыОтчетов КАК Отчеты
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ВариантыОтчетов.Размещение КАК РазмещениеОтчетов
	|		ПО РазмещениеОтчетов.Ссылка = Отчеты.Ссылка
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетов КАК ОтчетыКонфигурации
	|		ПО ОтчетыКонфигурации.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетов.Размещение КАК РазмещениеОтчетовКонфигурации
	|		ПО РазмещениеОтчетовКонфигурации.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетовРасширений КАК ОтчетыРасширений
	|		ПО ОтчетыРасширений.Ссылка = Отчеты.ПредопределенныйВариант
	|	ЛЕВОЕ СОЕДИНЕНИЕ Справочник.ПредопределенныеВариантыОтчетовРасширений.Размещение КАК РазмещениеОтчетовРасширений
	|		ПО РазмещениеОтчетовРасширений.Ссылка = Отчеты.ПредопределенныйВариант
	|ГДЕ
	|	ЕСТЬNULL(РазмещениеОтчетов.Использование, ИСТИНА) 
	|	И НЕ ЕСТЬNULL(РазмещениеОтчетов.Подсистема,
	|		ЕСТЬNULL(РазмещениеОтчетовКонфигурации.Подсистема, РазмещениеОтчетовРасширений.Подсистема)) ЕСТЬ NULL
	|;
	|
	|ВЫБРАТЬ
	|	Настройки.Вариант,
	|	Настройки.Подсистема,
	|	Настройки.Пользователь,
	|	Настройки.Видимость,
	|	Настройки.БыстрыйДоступ
	|ИЗ
	|	Настройки КАК Настройки
	|	ЛЕВОЕ СОЕДИНЕНИЕ РегистрСведений.НастройкиВариантовОтчетов КАК НастройкиСуществующие
	|		ПО НастройкиСуществующие.Вариант = Настройки.Вариант
	|		И НастройкиСуществующие.Подсистема = Настройки.Подсистема
	|ГДЕ
	|	Настройки.Видимость
	|	И НастройкиСуществующие.Вариант ЕСТЬ NULL");
	
	Ссылки = Запрос.Выполнить().Выгрузить().ВыгрузитьКолонку("Вариант");
	
	ОбновлениеИнформационнойБазы.ОтметитьКОбработке(Параметры, Ссылки);
	
КонецПроцедуры

// Обрабатывает данные, зарегистрированные в плане обмена ОбновлениеИнформационнойБазы
//  см. Стандарты и методики разработки прикладных решений: Параллельный режим отложенного обновления.
//
// Параметры:
//  Параметры - Структура - см. ОбновлениеИнформационнойБазы.ОсновныеПараметрыОтметкиКОбработке.
//
Процедура ОбработатьДанныеДляПереходаНаНовуюВерсию(Параметры) Экспорт 
	
	Вариант = ОбновлениеИнформационнойБазы.ВыбратьСсылкиДляОбработки(Параметры.Очередь, "Справочник.ВариантыОтчетов");
	
	Данные = Новый Структура("Вариант, Пользователь, Подсистема, Видимость, БыстрыйДоступ");
	Данные.Подсистема = Справочники.ИдентификаторыОбъектовМетаданных.ПустаяСсылка();
	Данные.Видимость = Истина;
	Данные.БыстрыйДоступ = Ложь;
	
	МетаданныеРегистра = Метаданные.РегистрыСведений.НастройкиВариантовОтчетов;
	ПредставлениеРегистра = МетаданныеРегистра.Представление();
	
	Обработано = 0;
	Отказано = 0;
	
	#Область ОбработкаДанных
	
	Пока Вариант.Следующий() Цикл
		
		Данные.Вариант = Вариант.Ссылка;
		
		Попытка
			
			ПеренестиНастройкиДоступностиВариантаОтчета(Данные);
			Обработано = Обработано + 1;
			
		Исключение
			
			Отказано = Отказано + 1;
			
			ШаблонКомментария = НСтр("ru = 'Не удалось перенести настройки доступности варианта отчета ""%1"" в регистр ""%2""
				|по причине: %3'");
				
			Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				ШаблонКомментария,
				Вариант.Ссылка,
				ПредставлениеРегистра,
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			ЗаписьЖурналаРегистрации(
				ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
				УровеньЖурналаРегистрации.Предупреждение,
				МетаданныеРегистра,,
				Комментарий);
			
		КонецПопытки;
		
	КонецЦикла;
	
	#КонецОбласти
	
	#Область ОбработкаСтатистики
	
	Параметры.ОбработкаЗавершена = ОбновлениеИнформационнойБазы.ОбработкаДанныхЗавершена(
		Параметры.Очередь, Метаданные.Справочники.ВариантыОтчетов.ПолноеИмя());
	
	Если Обработано = 0 И Отказано <> 0 Тогда
		
		ШаблонСообщения = НСтр("ru = 'Процедуре ПеренестиНастройкиДоступностиВариантаОтчета не удалось обработать некоторые данные: %1'");
		ТекстСообщения = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонСообщения, Отказано);
		
		ВызватьИсключение ТекстСообщения;
		
	Иначе
		
		ШаблонКомментария = НСтр("ru = 'Процедура ПеренестиНастройкиДоступностиВариантаОтчета обработала очередной пакет данных: %1'");
		Комментарий = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(ШаблонКомментария, Обработано);
		
		ЗаписьЖурналаРегистрации(
			ОбновлениеИнформационнойБазы.СобытиеЖурналаРегистрации(),
			УровеньЖурналаРегистрации.Информация,
			МетаданныеРегистра,,
			Комментарий);
		
	КонецЕсли;
	
	#КонецОбласти
	
КонецПроцедуры

Процедура ПеренестиНастройкиДоступностиВариантаОтчета(Данные)
	
	НачатьТранзакцию();
	
	Попытка
		
		Блокировка = Новый БлокировкаДанных;
		
		ЭлементБлокировки = Блокировка.Добавить("Справочник.ВариантыОтчетов");
		ЭлементБлокировки.УстановитьЗначение("Ссылка", Данные.Вариант);
		
		ЭлементБлокировки = Блокировка.Добавить("РегистрСведений.НастройкиВариантовОтчетов");
		ЭлементБлокировки.УстановитьЗначение("Вариант", Данные.Вариант);
		
		Блокировка.Заблокировать();
		
		Записи = СоздатьНаборЗаписей();
		Записи.Отбор.Вариант.Установить(Данные.Вариант);
		Записи.Отбор.Пользователь.Установить(Данные.Пользователь);
		Записи.Отбор.Подсистема.Установить(Данные.Подсистема);
		
		Запись = Записи.Добавить();
		ЗаполнитьЗначенияСвойств(Запись, Данные);
		
		ОбновлениеИнформационнойБазы.ЗаписатьНаборЗаписей(Записи);
		ОбновлениеИнформационнойБазы.ОтметитьВыполнениеОбработки(Данные.Вариант);
		
		ЗафиксироватьТранзакцию();
		
	Исключение
		
		ОтменитьТранзакцию();
		ВызватьИсключение;
		
	КонецПопытки;
	
КонецПроцедуры

#КонецОбласти

#КонецЕсли