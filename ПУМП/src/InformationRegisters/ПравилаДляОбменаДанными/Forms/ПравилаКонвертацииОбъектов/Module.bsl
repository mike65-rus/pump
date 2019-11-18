///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОписаниеПеременных

&НаКлиенте
Перем ВнешниеРесурсыРазрешены;

#КонецОбласти

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьСписокВыбораПлановОбмена();
	
	ОбновитьСписокВыбораМакетаПравил();
	
	ОбновитьИнформациюОПравилах();
	
	ИсточникПравил = ?(Запись.ИсточникПравил = Перечисления.ИсточникиПравилДляОбменаДанными.МакетКонфигурации,
		"ТиповыеИзКонфигурации", "ЗагруженныеИзФайла");
	Элементы.ГруппаПланаОбмена.Видимость = ПустаяСтрока(Запись.ИмяПланаОбмена);
	
	Элементы.ГруппаОтладки.Доступность = (ИсточникПравил = "ЗагруженныеИзФайла");
	Элементы.ГруппаНастройкиОтладки.Доступность = Запись.РежимОтладки;
	Элементы.ИсточникФайл.Доступность = (ИсточникПравил = "ЗагруженныеИзФайла");
	
	СобытиеЖурналаРегистрацииЗагрузкаПравилДляОбменаДанными = ОбменДаннымиСервер.СобытиеЖурналаРегистрацииЗагрузкаПравилДляОбменаДанными();
	
КонецПроцедуры

&НаКлиенте
Процедура ПередЗаписью(Отказ, ПараметрыЗаписи)
	
	Если Не ПроверитьЗаполнениеНаКлиенте() Тогда
		Отказ = Истина;
		Возврат;
	КонецЕсли;
	
	Если ВнешниеРесурсыРазрешены <> Истина Тогда
		
		ОповещениеОЗакрытии = Новый ОписаниеОповещения("РазрешитьВнешнийРесурсЗавершение", ЭтотОбъект, ПараметрыЗаписи);
		Если ОбщегоНазначенияКлиент.ПодсистемаСуществует("СтандартныеПодсистемы.ПрофилиБезопасности") Тогда
			Запросы = СоздатьЗапросНаИспользованиеВнешнихРесурсов(Запись);
			МодульРаботаВБезопасномРежимеКлиент = ОбщегоНазначенияКлиент.ОбщийМодуль("РаботаВБезопасномРежимеКлиент");
			МодульРаботаВБезопасномРежимеКлиент.ПрименитьЗапросыНаИспользованиеВнешнихРесурсов(Запросы, ЭтотОбъект, ОповещениеОЗакрытии);
		Иначе
			ВыполнитьОбработкуОповещения(ОповещениеОЗакрытии, КодВозвратаДиалога.ОК);
		КонецЕсли;
		
		Отказ = Истина;
		Возврат;
		
	КонецЕсли;
	ВнешниеРесурсыРазрешены = Ложь;
	
	Если ИсточникПравил = "ТиповыеИзКонфигурации" Тогда
		// Из конфигурации
		ВыполнитьЗагрузкуПравил(Неопределено, "", Ложь);
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Функция ПроверитьЗаполнениеНаКлиенте()
	
	ЕстьНезаполненныеПоля = Ложь;
	
	Если ИсточникПравил = "ЗагруженныеИзФайла" И ПустаяСтрока(Запись.ИмяФайлаПравил) Тогда
		
		СтрокаСообщения = НСтр("ru = 'Не задан файл правил обмена.'");
		ОбщегоНазначенияКлиент.СообщитьПользователю(СтрокаСообщения,,,, ЕстьНезаполненныеПоля);
		
	КонецЕсли;
	
	Если Запись.РежимОтладки Тогда
		
		Если Запись.РежимОтладкиВыгрузки Тогда
			
			СтруктураИмениФайла = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Запись.ИмяФайлаОбработкиДляОтладкиВыгрузки);
			ИмяФайла = СтруктураИмениФайла.ИмяБезРасширения;
			
			Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
				
				СтрокаСообщения = НСтр("ru = 'Не задано имя файла внешней обработки.'");
				ОбщегоНазначенияКлиент.СообщитьПользователю(СтрокаСообщения,, "Запись.ИмяФайлаОбработкиДляОтладкиВыгрузки",, ЕстьНезаполненныеПоля);
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если Запись.РежимОтладкиЗагрузки Тогда
			
			СтруктураИмениФайла = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Запись.ИмяФайлаОбработкиДляОтладкиЗагрузки);
			ИмяФайла = СтруктураИмениФайла.ИмяБезРасширения;
			
			Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
				
				СтрокаСообщения = НСтр("ru = 'Не задано имя файла внешней обработки.'");
				ОбщегоНазначенияКлиент.СообщитьПользователю(СтрокаСообщения,, "Запись.ИмяФайлаОбработкиДляОтладкиЗагрузки",, ЕстьНезаполненныеПоля);
				
			КонецЕсли;
			
		КонецЕсли;
		
		Если Запись.РежимПротоколированияОбменаДанными Тогда
			
			СтруктураИмениФайла = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Запись.ИмяФайлаПротоколаОбмена);
			ИмяФайла = СтруктураИмениФайла.ИмяБезРасширения;
			
			Если Не ЗначениеЗаполнено(ИмяФайла) Тогда
				
				СтрокаСообщения = НСтр("ru = 'Не задано имя файла протокола обмена.'");
				ОбщегоНазначенияКлиент.СообщитьПользователю(СтрокаСообщения,, "Запись.ИмяФайлаПротоколаОбмена",, ЕстьНезаполненныеПоля);
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	Возврат Не ЕстьНезаполненныеПоля;
	
КонецФункции

&НаКлиенте
Процедура ПослеЗаписи(ПараметрыЗаписи)
	
	Если ПараметрыЗаписи.Свойство("ЗаписатьИЗакрыть") Тогда
		Закрыть();
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиСобытийЭлементовШапкиФормы

&НаКлиенте
Процедура ИмяПланаОбменаПриИзменении(Элемент)
	
	Запись.ИмяМакетаПравил = "";
	
	// вызов сервера
	ОбновитьСписокВыбораМакетаПравил();
	
КонецПроцедуры

&НаКлиенте
Процедура ИсточникПравилПриИзменении(Элемент)
	
	Элементы.ГруппаОтладки.Доступность = (ИсточникПравил = "ЗагруженныеИзФайла");
	Элементы.ИсточникФайл.Доступность = (ИсточникПравил = "ЗагруженныеИзФайла");
	
	Если ИсточникПравил = "ТиповыеИзКонфигурации" Тогда
		
		Запись.РежимОтладки = Ложь;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтладкуВыгрузкиПриИзменении(Элемент)
	
	Элементы.ВнешняяОбработкаДляОтладкиВыгрузки.Доступность = Запись.РежимОтладкиВыгрузки;
	
КонецПроцедуры

&НаКлиенте
Процедура ВнешняяОбработкаДляОтладкиВыгрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Внешняя обработка (*.epf)'") + "|*.epf" );
	
	ОбменДаннымиКлиент.ОбработчикВыбораФайла(Запись, "ИмяФайлаОбработкиДляОтладкиВыгрузки", СтандартнаяОбработка, НастройкиДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ВнешняяОбработкаДляОтладкиЗагрузкиНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Внешняя обработка (*.epf)'") + "|*.epf" );
	
	СтандартнаяОбработка = Ложь;
	ОбменДаннымиКлиент.ОбработчикВыбораФайла(Запись, "ИмяФайлаОбработкиДляОтладкиЗагрузки", СтандартнаяОбработка, НастройкиДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьОтладкуЗагрузкиПриИзменении(Элемент)
	
	Элементы.ВнешняяОбработкаДляОтладкиЗагрузки.Доступность = Запись.РежимОтладкиЗагрузки;
	
КонецПроцедуры

&НаКлиенте
Процедура ВключитьПротоколированиеОбменаДаннымиПриИзменении(Элемент)
	
	Элементы.ФайлПротоколаОбмена.Доступность = Запись.РежимПротоколированияОбменаДанными;
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлПротоколаОбменаНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	НастройкиДиалога = Новый Структура;
	НастройкиДиалога.Вставить("Фильтр", НСтр("ru = 'Текстовый документ (*.txt)'")+ "|*.txt" );
	НастройкиДиалога.Вставить("ПроверятьСуществованиеФайла", Ложь);
	
	СтандартнаяОбработка = Ложь;
	ОбменДаннымиКлиент.ОбработчикВыбораФайла(Запись, "ИмяФайлаПротоколаОбмена", СтандартнаяОбработка, НастройкиДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ФайлПротоколаОбменаОткрытие(Элемент, СтандартнаяОбработка)
	
	ОбменДаннымиКлиент.ОбработчикОткрытияФайлаИлиКаталога(Запись, "ИмяФайлаПротоколаОбмена", СтандартнаяОбработка);
	
КонецПроцедуры

&НаКлиенте
Процедура ИмяМакетаПравилПриИзменении(Элемент)
	Запись.ИмяМакетаПравилКорреспондента = Запись.ИмяМакетаПравил + "Корреспондента";
КонецПроцедуры

&НаКлиенте
Процедура ВключитьРежимОтладкиПриИзменении(Элемент)
	
	Элементы.ГруппаНастройкиОтладки.Доступность = Запись.РежимОтладки;
	
КонецПроцедуры

#КонецОбласти

#Область ОбработчикиКомандФормы

&НаКлиенте
Процедура ЗагрузитьПравила(Команда)
	
	// Из файла с клиента
	ЧастиИмени = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Запись.ИмяФайлаПравил);
	
	ПараметрыДиалога = Новый Структура;
	ПараметрыДиалога.Вставить("Заголовок", НСтр("ru = 'Укажите архив с правилами обмена'"));
	ПараметрыДиалога.Вставить("Фильтр", НСтр("ru = 'Архивы ZIP (*.zip)'") + "|*.zip");
	ПараметрыДиалога.Вставить("ПолноеИмяФайла", ЧастиИмени.ПолноеИмя);
	
	Оповещение = Новый ОписаниеОповещения("ЗагрузитьПравилаЗавершение", ЭтотОбъект);
	ОбменДаннымиКлиент.ВыбратьИПередатьФайлНаСервер(Оповещение, ПараметрыДиалога, УникальныйИдентификатор);
	
КонецПроцедуры

&НаКлиенте
Процедура ВыгрузитьПравила(Команда)
	
	ЧастиИмени = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(Запись.ИмяФайлаПравил);

	// Выгружаем как архив
	АдресХранения = ПолучитьАдресВременногоХранилищаАрхиваПравилНаСервере();
	
	Если ПустаяСтрока(АдресХранения) Тогда
		Возврат;
	КонецЕсли;
	
	Если ПустаяСтрока(ЧастиИмени.ИмяБезРасширения) Тогда
		ПолноеИмяФайла = НСтр("ru = 'Правила конвертации'");
	Иначе
		ПолноеИмяФайла = ЧастиИмени.ИмяБезРасширения;
	КонецЕсли;
	
	ПараметрыДиалога = Новый Структура;
	ПараметрыДиалога.Вставить("Режим", РежимДиалогаВыбораФайла.Сохранение);
	ПараметрыДиалога.Вставить("Заголовок", НСтр("ru = 'Укажите в какой файл выгрузить правила'") );
	ПараметрыДиалога.Вставить("ПолноеИмяФайла", ПолноеИмяФайла);
	ПараметрыДиалога.Вставить("Фильтр", НСтр("ru = 'Архивы ZIP (*.zip)'") + "|*.zip");
	
	ПолучаемыйФайл = Новый Структура("Имя, Хранение", ПолноеИмяФайла, АдресХранения);
	
	ОбменДаннымиКлиент.ВыбратьИСохранитьФайлНаКлиенте(ПолучаемыйФайл, ПараметрыДиалога);
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаписатьИЗакрыть(Команда)
	
	ПараметрыЗаписи = Новый Структура;
	ПараметрыЗаписи.Вставить("ЗаписатьИЗакрыть");
	Записать(ПараметрыЗаписи);
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

&НаСервере
Процедура ОбновитьСписокВыбораПлановОбмена()
	
	СписокПлановОбмена = ОбменДаннымиПовтИсп.СписокПлановОбменаБСП();
	
	ЗаполнитьСписок(СписокПлановОбмена, Элементы.ИмяПланаОбмена.СписокВыбора);
	
КонецПроцедуры

&НаСервере
Процедура ОбновитьСписокВыбораМакетаПравил()
	
	Если ПустаяСтрока(Запись.ИмяПланаОбмена) Тогда
		
		Элементы.ГруппаОсновная.Заголовок = НСтр("ru = 'Правила конвертации'");
		
	Иначе
		
		Элементы.ГруппаОсновная.Заголовок = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			Элементы.ГруппаОсновная.Заголовок, Метаданные.ПланыОбмена[Запись.ИмяПланаОбмена].Синоним);
		
	КонецЕсли;
	
	СписокМакетов = ОбменДаннымиПовтИсп.ПравилаКонвертацииДляПланаОбменаИзКонфигурации(Запись.ИмяПланаОбмена);
	
	СписокВыбора = Элементы.ИмяМакетаПравил.СписокВыбора;
	СписокВыбора.Очистить();
	
	ЗаполнитьСписок(СписокМакетов, СписокВыбора);
	
	Элементы.ИсточникМакетКонфигурации.ТекущаяСтраница = ?(СписокМакетов.Количество() = 1,
		Элементы.СтраницаОдинМакет, Элементы.СтраницаНесколькоМакетов);
	
КонецПроцедуры

&НаСервере
Процедура ЗаполнитьСписок(СписокИсточник, СписокПриемник)
	
	Для Каждого Элемент Из СписокИсточник Цикл
		
		ЗаполнитьЗначенияСвойств(СписокПриемник.Добавить(), Элемент);
		
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗагрузитьПравилаЗавершение(Знач РезультатПомещенияФайлов, Знач ДополнительныеПараметры) Экспорт
	
	АдресПомещенногоФайла = РезультатПомещенияФайлов.Хранение;
	ТекстОшибки           = РезультатПомещенияФайлов.ОписаниеОшибки;
	
	Если ПустаяСтрока(ТекстОшибки) И ПустаяСтрока(АдресПомещенногоФайла) Тогда
		ТекстОшибки = НСтр("ru = 'Ошибка передачи файла настроек синхронизации данных на сервер'");
	КонецЕсли;
	
	Если Не ПустаяСтрока(ТекстОшибки) Тогда
		ОбщегоНазначенияКлиент.СообщитьПользователю(ТекстОшибки);
		Возврат;
	КонецЕсли;
		
	// Успешно передали файл, загружаем на сервере.
	ЧастиИмени = ОбщегоНазначенияКлиентСервер.РазложитьПолноеИмяФайла(РезультатПомещенияФайлов.Имя);
	
	ВыполнитьЗагрузкуПравил(АдресПомещенногоФайла, ЧастиИмени.Имя, НРег(ЧастиИмени.Расширение) = ".zip");
	
КонецПроцедуры

&НаКлиенте
Процедура ВыполнитьЗагрузкуПравил(Знач АдресПомещенногоФайла, Знач ИмяФайла, Знач ЭтоАрхив)
	Отказ = Ложь;
	
	ЗагрузитьПравилаНаСервере(Отказ, АдресПомещенногоФайла, ИмяФайла, ЭтоАрхив);
	
	Если Не Отказ Тогда
		ПоказатьОповещениеПользователя(,, НСтр("ru = 'Правила успешно загружены в информационную базу.'"));
		Возврат;
	КонецЕсли;
	
	ТекстОшибки = НСтр("ru = 'В процессе загрузки правил были обнаружены ошибки.
	                         |Перейти в журнал регистрации?'");
	
	Оповещение = Новый ОписаниеОповещения("ПоказатьЖурналРегистрацииПриОшибке", ЭтотОбъект);
	ПоказатьВопрос(Оповещение, ТекстОшибки, РежимДиалогаВопрос.ДаНет, ,КодВозвратаДиалога.Нет);
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьЖурналРегистрацииПриОшибке(Ответ, ДополнительныеПараметры) Экспорт
	
	Если Ответ = КодВозвратаДиалога.Да Тогда
		
		Отбор = Новый Структура;
		Отбор.Вставить("СобытиеЖурналаРегистрации", СобытиеЖурналаРегистрацииЗагрузкаПравилДляОбменаДанными);
		ОткрытьФорму("Обработка.ЖурналРегистрации.Форма", Отбор, ЭтотОбъект, , , , , РежимОткрытияОкнаФормы.БлокироватьОкноВладельца);
		
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ЗагрузитьПравилаНаСервере(Отказ, АдресВременногоХранилища, ИмяФайлаПравил, ЭтоАрхив)
	
	Запись.ИсточникПравил = ?(ИсточникПравил = "ТиповыеИзКонфигурации",
		Перечисления.ИсточникиПравилДляОбменаДанными.МакетКонфигурации, Перечисления.ИсточникиПравилДляОбменаДанными.Файл);
	
	Объект = РеквизитФормыВЗначение("Запись");
	
	РегистрыСведений.ПравилаДляОбменаДанными.ЗагрузитьПравила(Отказ, Объект, АдресВременногоХранилища, ИмяФайлаПравил, ЭтоАрхив);
	
	Если Не Отказ Тогда
		
		Объект.Записать();
		
		Модифицированность = Ложь;
		
		// Кэш открытых сеансов для механизма регистрации стал неактуальным.
		ОбменДаннымиСлужебный.СброситьКэшМеханизмаРегистрацииОбъектов();
		ОбновитьПовторноИспользуемыеЗначения();
	КонецЕсли;
	
	ЗначениеВРеквизитФормы(Объект, "Запись");
	
	ОбновитьИнформациюОПравилах();
	
КонецПроцедуры

&НаСервере
Функция ПолучитьАдресВременногоХранилищаАрхиваПравилНаСервере()
	
	// Создаем временный каталог на сервере и формируем пути к файлам и папкам.
	ИмяВременнойПапки = ПолучитьИмяВременногоФайла("");
	СоздатьКаталог(ИмяВременнойПапки);
	ПутьКФайлу = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяВременнойПапки) + "ExchangeRules";
	ПутьКФайлуКорреспондента = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяВременнойПапки) + "CorrespondentExchangeRules";
	
	Запрос = Новый Запрос;
	Запрос.Текст =
	"ВЫБРАТЬ
	|	ПравилаДляОбменаДанными.ПравилаXML,
	|	ПравилаДляОбменаДанными.ПравилаXMLКорреспондента
	|ИЗ
	|	РегистрСведений.ПравилаДляОбменаДанными КАК ПравилаДляОбменаДанными
	|ГДЕ
	|	ПравилаДляОбменаДанными.ИмяПланаОбмена = &ИмяПланаОбмена
	|	И ПравилаДляОбменаДанными.ВидПравил = &ВидПравил";
	Запрос.УстановитьПараметр("ИмяПланаОбмена", Запись.ИмяПланаОбмена); 
	Запрос.УстановитьПараметр("ВидПравил", Запись.ВидПравил);
	Результат = Запрос.Выполнить();
	Если Результат.Пустой() Тогда
		
		НСтрока = НСтр("ru = 'Не удалось получить правила обмена.'");
		ОбменДаннымиСервер.СообщитьОбОшибке(НСтрока);
		УдалитьФайлы(ИмяВременнойПапки);
		Возврат "";
		
	Иначе
		
		Выборка = Результат.Выбрать();
		Выборка.Следующий();
		
		// Получаем, сохраняем и архивируем файл правил во временном каталоге.
		ДвоичныеДанныеПравил = Выборка.ПравилаXML.Получить(); // ДвоичныеДанные
		ДвоичныеДанныеПравил.Записать(ПутьКФайлу + ".xml");
		
		ДвоичныеДанныеПравилКорреспондента = Выборка.ПравилаXMLКорреспондента.Получить(); // ДвоичныеДанные
		ДвоичныеДанныеПравилКорреспондента.Записать(ПутьКФайлуКорреспондента + ".xml");
		
		МаскаУпаковкиФайлов = ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ИмяВременнойПапки) + "*.xml";
		ОбменДаннымиСервер.ЗапаковатьВZipФайл(ПутьКФайлу + ".zip", МаскаУпаковкиФайлов);
		
		// Помещаем архив правил в хранилище.
		ДвоичныеДанныеАрхиваПравил = Новый ДвоичныеДанные(ПутьКФайлу + ".zip");
		АдресВременногоХранилища = ПоместитьВоВременноеХранилище(ДвоичныеДанныеАрхиваПравил);
		УдалитьФайлы(ИмяВременнойПапки);
		Возврат АдресВременногоХранилища;
		
	КонецЕсли;
	
КонецФункции

&НаСервере
Процедура ОбновитьИнформациюОПравилах()
	
	Если Запись.ИсточникПравил = Перечисления.ИсточникиПравилДляОбменаДанными.Файл Тогда
		
		ИнформацияОПравилах = НСтр("ru = 'Использование правил, загруженных из файла,
		|может привести к ошибкам при переходе на новую версию программы.
		|
		|[ИнформацияОПравилах]'");
		
		ИнформацияОПравилах = СтрЗаменить(ИнформацияОПравилах, "[ИнформацияОПравилах]", Запись.ИнформацияОПравилах);
		
	Иначе
		
		ИнформацияОПравилах = Запись.ИнформацияОПравилах;
		
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура РазрешитьВнешнийРесурсЗавершение(Результат, ПараметрыЗаписи) Экспорт
	
	Если Результат = КодВозвратаДиалога.ОК Тогда
		ВнешниеРесурсыРазрешены = Истина;
		Записать(ПараметрыЗаписи);
	КонецЕсли;
	
КонецПроцедуры

&НаСервереБезКонтекста
Функция СоздатьЗапросНаИспользованиеВнешнихРесурсов(Знач Запись)
	
	ЗапросыРазрешений = Новый Массив;
	ПравилаРегистрацииИзФайла = РегистрыСведений.ПравилаДляОбменаДанными.ПравилаРегистрацииИзФайла(Запись.ИмяПланаОбмена);
	РегистрыСведений.ПравилаДляОбменаДанными.ЗапросНаИспользованиеВнешнихРесурсов(ЗапросыРазрешений, Запись, Истина, ПравилаРегистрацииИзФайла);
	Возврат ЗапросыРазрешений;
	
КонецФункции

#КонецОбласти