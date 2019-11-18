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

// ИнтернетПоддержкаПользователей.РаботаСКлассификаторами

// См. РаботаСКлассификаторамиПереопределяемый.ПриДобавленииКлассификаторов.
Процедура ПриДобавленииКлассификаторов(Классификаторы, Описатель) Экспорт
	
	Описатель.Идентификатор = ИдентификаторКлассификатора();
	Описатель.Наименование = НСтр("ru = 'Банки (справочник по кредитным организациям)'");
	Описатель.ОбновлятьАвтоматически = Истина;
	Описатель.ОбщиеДанные = Истина;
	Описатель.ОбработкаРазделенныхДанных = Ложь;
	Описатель.СохранятьФайлВКэш = Истина;
	
	Классификаторы.Добавить(Описатель);
	
КонецПроцедуры

// См. РаботаСКлассификаторамиПереопределяемый.ПриЗагрузкеКлассификатора.
Процедура ПриЗагрузкеКлассификатора(Идентификатор, Версия, Адрес, Обработан, ДополнительныеПараметры) Экспорт
	
	Если Идентификатор <> ИдентификаторКлассификатора() Тогда
		Возврат;
	КонецЕсли;
	
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("zip");
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(Адрес);
	ДвоичныеДанные.Записать(ИмяВременногоФайла);
	ЗагрузитьДанныеИзФайла(ИмяВременногоФайла);
	УдалитьФайлы(ИмяВременногоФайла);
	
	Обработан = Истина;
	
КонецПроцедуры

// Конец ИнтернетПоддержкаПользователей.РаботаСКлассификаторами

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция ДоступнаЗагрузкаКлассификатора() Экспорт
	
	Результат = Ложь;
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.РаботаСКлассификаторами") Тогда
		МодульРаботаСКлассификаторами = ОбщегоНазначения.ОбщийМодуль("РаботаСКлассификаторами");
		Результат = МодульРаботаСКлассификаторами.ИнтерактивнаяЗагрузкаКлассификаторовДоступна();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Процедура ПриПолученииДанныхКлассификатора(Параметры, СтандартнаяОбработка) Экспорт
	СтандартнаяОбработка = Истина;
КонецПроцедуры

Процедура ЗагрузитьДанные(Параметры)
	
	Регионы = Регионы(Параметры.ПутьКФайлуРегионов);
	
	ЧтениеТекста = Новый ЧтениеТекста(Параметры.ПутьКФайлуБИК, "windows-1251");
	ТекстКлассификатора = ЧтениеТекста.Прочитать();
	ЧтениеТекста.Закрыть();
	
	Для Каждого Строка Из СтрРазделить(ТекстКлассификатора, Символы.ПС, Ложь) Цикл 
		СведенияОБанке = СведенияОБанке(Строка, Регионы);
		Если СведенияОБанке = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ЗаписатьЭлементКлассификатораБанковРФ(СведенияОБанке);
	КонецЦикла;
	
	// Пометка недействующих банков.
	ДействующиеБанки = ДействующиеБанкиИзФайла(Параметры.ПутьКФайлуБИК);
	НедействующиеБанки = НедействующиеБанкиИзФайла(Параметры.ПутьКФайлуНедействующихБанков);
	ОтметитьНедействующиеБанки(ДействующиеБанки, НедействующиеБанки);
	
КонецПроцедуры

Функция ОпределитьТипГородаПоКоду(КодТипа)
	
	Если КодТипа = "1" Тогда
		Возврат "Г.";       // ГОРОД
	ИначеЕсли КодТипа = "2" Тогда
		Возврат "П.";       // ПОСЕЛОК
	ИначеЕсли КодТипа = "3" Тогда
		Возврат "С.";       // СЕЛО
	ИначеЕсли КодТипа = "4" Тогда
		Возврат "ПГТ";     // ПОСЕЛОК ГОРОДСКОГО ТИПА
	ИначеЕсли КодТипа = "5" Тогда
		Возврат "СТ-ЦА";   // СТАНИЦА
	ИначеЕсли КодТипа = "6" Тогда
		Возврат "АУЛ";     // АУЛ
	ИначеЕсли КодТипа = "7" Тогда
		Возврат "РП";      // РАБОЧИЙ ПОСЕЛОК 
	Иначе
		Возврат "";
	КонецЕсли;
	
КонецФункции

Функция Регионы(ПутьКФайлуРегионов)
	
	СоответствиеРегионов = Новый Соответствие;
	РегионыТекстовыйДокумент = Новый ЧтениеТекста(ПутьКФайлуРегионов, "windows-1251");
	СтрокаРегионов = РегионыТекстовыйДокумент.ПрочитатьСтроку();
	
	Пока СтрокаРегионов <> Неопределено Цикл

		Строка  = СтрокаРегионов;
		СтрокаРегионов = РегионыТекстовыйДокумент.ПрочитатьСтроку();

		Если (Лев(Строка,2) = "//") Или (ПустаяСтрока(Строка)) Тогда
			Продолжить;
		КонецЕсли;
		
		МассивПодстрок = СтрРазделить(Строка, Символы.Таб);
		
		Если МассивПодстрок.Количество() < 2 Тогда
			Продолжить;
		КонецЕсли;	
		
		Символ1 = СокрЛП(МассивПодстрок[0]);
        Символ2 = СокрЛП(МассивПодстрок[1]);
        		 		
		// Дополним код региона до двух знаков.
		Если СтрДлина(Символ1) = 1 Тогда
			Символ1 = "0" + Символ1;
		КонецЕсли;
		
		СоответствиеРегионов.Вставить(Символ1, Символ2);
 	КонецЦикла;	
		
	Возврат СоответствиеРегионов;

КонецФункции

// Формирует структуру полей для банка.
// Параметры:
//	Строка  - Строка	   - Строка из текстового файла классификатора.
//	Регионы - Соответствие - Код региона и регион банка.
// Возвращаемое значение:
//	Банк - Структура - Реквизиты банка.
//
Функция СведенияОБанке(Знач Строка, Регионы)
	
	Результат = Новый Структура;
	
	СписокПолей = Новый Массив;
	СписокПолей.Добавить("ТипУчастникаРасчетов");
	СписокПолей.Добавить("ИмяНаселенногоПункта");
	СписокПолей.Добавить("ТипПункта");
	СписокПолей.Добавить("Наименование");
	СписокПолей.Добавить("ПризнакКода");
	СписокПолей.Добавить("БИК");
	СписокПолей.Добавить("КоррСчет");
	СписокПолей.Добавить("СВИФТБИК");
	СписокПолей.Добавить("ИНН");
	СписокПолей.Добавить("ОГРН");
	СписокПолей.Добавить("Адрес");
	СписокПолей.Добавить("Телефоны");
	СписокПолей.Добавить("МеждународноеНаименование");
	СписокПолей.Добавить("ГородМеждународный");
	СписокПолей.Добавить("АдресМеждународный");
	
	КоллекцияЗначений = СтрРазделить(Строка, Символы.Таб, Истина);
	Для Индекс = 0 По СписокПолей.Количество() - 1 Цикл;
		Значение = "";
		Если Индекс <= КоллекцияЗначений.ВГраница() Тогда
			Значение = СокрЛП(КоллекцияЗначений[Индекс]);
		КонецЕсли;
		Результат.Вставить(СписокПолей[Индекс], Значение);
	КонецЦикла;
	
	Если СтрДлина(Результат.БИК) <> 9 Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Результат.ТипПункта = ОпределитьТипГородаПоКоду(Результат.ТипПункта);
	Результат.Вставить("Город", СокрЛП(Результат.ТипПункта + " " + Результат.ИмяНаселенногоПункта));
	
	КодРегиона = Сред(Результат.БИК, 3, 2);
	Регион = Регионы[КодРегиона];
	Если Регион = Неопределено Тогда
		Регион = НСтр("ru = 'Другие территории'");
		КодРегиона = "";
	КонецЕсли;
	
	Результат.Вставить("КодРегиона", КодРегиона);
	Результат.Вставить("Регион", Регион);
	
	Возврат Результат;
	
КонецФункции

// Выполняет загрузку классификатора банков РФ из файла, полученного с сайта 1С.
Процедура ЗагрузитьДанныеИзФайла(ИмяФайла)
	
	ПапкаСИзвлеченнымиФайлами = ИзвлечьФайлыИзАрхива(ИмяФайла);
	Если ФайлыКлассификатораПолучены(ПапкаСИзвлеченнымиФайлами) Тогда
		Параметры = Новый Структура;
		ФайлБИКСВИФТ = Новый Файл(ИмяФайлаБИКСВИФТ(ПапкаСИзвлеченнымиФайлами));
		Если ФайлБИКСВИФТ.Существует() Тогда
			Параметры.Вставить("ПутьКФайлуБИК", ИмяФайлаБИКСВИФТ(ПапкаСИзвлеченнымиФайлами));
		Иначе
			Параметры.Вставить("ПутьКФайлуБИК", ИмяФайлаБИК(ПапкаСИзвлеченнымиФайлами));
		КонецЕсли;
		Параметры.Вставить("ПутьКФайлуРегионов", ИмяФайлаРегионов(ПапкаСИзвлеченнымиФайлами));
		Параметры.Вставить("ПутьКФайлуНедействующихБанков", ИмяФайлаНедействующихБанков(ПапкаСИзвлеченнымиФайлами));
		Параметры.Вставить("ТекстСообщения", "");
		Параметры.Вставить("ЗагрузкаВыполнена", Неопределено);
		
		ЗагрузитьДанные(Параметры);
		УстановитьВерсиюКлассификатора();
	КонецЕсли;
	
КонецПроцедуры

Функция ФайлыКлассификатораПолучены(ПапкаСФайлами)
	
	Результат = Истина;
	
	ИменаФайловДляПроверки = Новый Массив;
	ИменаФайловДляПроверки.Добавить(ИмяФайлаБИК(ПапкаСФайлами));
	ИменаФайловДляПроверки.Добавить(ИмяФайлаРегионов(ПапкаСФайлами));
	ИменаФайловДляПроверки.Добавить(ИмяФайлаНедействующихБанков(ПапкаСФайлами));
	
	Для Каждого ИмяФайла Из ИменаФайловДляПроверки Цикл
		Файл = Новый Файл(ИмяФайла);
		Если Не Файл.Существует() Тогда
			ЗаписатьОшибкуВЖурналРегистрации(СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(НСтр("ru = 'Не найден файл %1'"), ИмяФайла));
			Результат = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ИзвлечьФайлыИзАрхива(ZipФайл)
	
	ВременнаяПапка = ПолучитьИмяВременногоФайла();
	СоздатьКаталог(ВременнаяПапка);
	
	Попытка
		ЧтениеZipФайла = Новый ЧтениеZipФайла(ZipФайл);
		ЧтениеZipФайла.ИзвлечьВсе(ВременнаяПапка);
	Исключение
		ЗаписатьОшибкуВЖурналРегистрации(ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
		УдалитьФайлы(ВременнаяПапка);
	КонецПопытки;
	
	Возврат ВременнаяПапка;
	
КонецФункции

Функция ИмяФайлаРегионов(ПапкаСФайламиКлассификатора)
	
	Возврат ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПапкаСФайламиКлассификатора) + "reg.txt";
	
КонецФункции

Функция ИмяФайлаБИК(ПапкаСФайламиКлассификатора)
	
	Возврат ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПапкаСФайламиКлассификатора) + "bnkseek.txt";
	
КонецФункции

Функция ИмяФайлаБИКСВИФТ(ПапкаСФайламиКлассификатора)
	
	Возврат ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПапкаСФайламиКлассификатора) + "bnkseek_swift.txt";
	
КонецФункции

Функция ИмяФайлаНедействующихБанков(ПапкаСФайламиКлассификатора)
	
	Возврат ОбщегоНазначенияКлиентСервер.ДобавитьКонечныйРазделительПути(ПапкаСФайламиКлассификатора) + "bnkdel.txt";
	
КонецФункции

Процедура ЗаписатьОшибкуВЖурналРегистрации(ТекстОшибки)
	
	ЗаписьЖурналаРегистрации(ИмяСобытияВЖурналеРегистрации(), УровеньЖурналаРегистрации.Ошибка,,, ТекстОшибки);
	
КонецПроцедуры

Функция ИмяСобытияВЖурналеРегистрации()
	
	Возврат НСтр("ru = 'Загрузка классификатора банков.ИПП'", ОбщегоНазначения.КодОсновногоЯзыка());
	
КонецФункции

Функция НедействующиеБанкиИзФайла(ПутьКФайлу)
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("БИК", Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(9)));
	Результат.Колонки.Добавить("Наименование", Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(100)));
	Результат.Колонки.Добавить("ДатаЗакрытия", Новый ОписаниеТипов("Дата",,,Новый КвалификаторыДаты(ЧастиДаты.Дата)));
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу, "windows-1251");
	
	Строка = ЧтениеТекста.ПрочитатьСтроку();
	Пока Строка <> Неопределено Цикл
		СведенияОБанке = СтрРазделить(Строка, Символы.Таб);
		Если СведенияОБанке.Количество() <> 8 Тогда
			Продолжить;
		КонецЕсли;
		Банк = Результат.Добавить();
		Банк.БИК = СведенияОБанке[6];
		Банк.Наименование = СведенияОБанке[4];
		Банк.ДатаЗакрытия = СведенияОБанке[1];
		
		Строка = ЧтениеТекста.ПрочитатьСтроку();
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ДействующиеБанкиИзФайла(ПутьКФайлу)
	
	Результат = Новый ТаблицаЗначений;
	Результат.Колонки.Добавить("БИК", Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(9)));
	Результат.Колонки.Добавить("Наименование", Новый ОписаниеТипов("Строка",,Новый КвалификаторыСтроки(100)));
	
	ЧтениеТекста = Новый ЧтениеТекста(ПутьКФайлу, "windows-1251");
	
	Строка = ЧтениеТекста.ПрочитатьСтроку();
	Пока Строка <> Неопределено Цикл
		СведенияОБанке = СтрРазделить(Строка, Символы.Таб);
		Строка = ЧтениеТекста.ПрочитатьСтроку();
		
		Если СведенияОБанке.Количество() < 7 Тогда
			Продолжить;
		КонецЕсли;
		Банк = Результат.Добавить();
		Банк.БИК = СведенияОБанке[5];
		Банк.Наименование = СведенияОБанке[3];
	КонецЦикла;
	
	Возврат Результат;
	
КонецФункции

Функция ОтметитьНедействующиеБанки(ДействующиеБанки, НедействующиеБанки)
	
	Запрос = Новый Запрос;
	Запрос.МенеджерВременныхТаблиц = Новый МенеджерВременныхТаблиц;
	
	Запрос.Текст = 
	"ВЫБРАТЬ
	|	НедействующиеБанки.БИК КАК БИК
	|ПОМЕСТИТЬ НедействующиеБанки
	|ИЗ
	|	&НедействующиеБанки КАК НедействующиеБанки
	|ГДЕ
	|	НЕ НедействующиеБанки.БИК В (&БИК)
	|
	|ИНДЕКСИРОВАТЬ ПО
	|	БИК";
	Запрос.УстановитьПараметр("НедействующиеБанки", НедействующиеБанки);
	Запрос.УстановитьПараметр("БИК", ДействующиеБанки.ВыгрузитьКолонку("БИК"));
	Запрос.Выполнить();
	
	Запрос.Текст =
	"ВЫБРАТЬ
	|	КлассификаторБанков.Ссылка
	|ИЗ
	|	НедействующиеБанки КАК НедействующиеБанки
	|		ВНУТРЕННЕЕ СОЕДИНЕНИЕ Справочник.КлассификаторБанков КАК КлассификаторБанков
	|		ПО НедействующиеБанки.БИК = КлассификаторБанков.Код
	|ГДЕ
	|	КлассификаторБанков.ДеятельностьПрекращена = ЛОЖЬ
	|
	|СГРУППИРОВАТЬ ПО
	|	КлассификаторБанков.Ссылка";
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.КлассификаторБанков");
		Блокировка.Заблокировать();
		
		ВыборкаБанков = Запрос.Выполнить().Выбрать();
		Пока ВыборкаБанков.Следующий() Цикл
			БанкОбъект = ВыборкаБанков.Ссылка.ПолучитьОбъект();
			БанкОбъект.ДеятельностьПрекращена = Истина;
			БанкОбъект.Записать();
		КонецЦикла;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
	Возврат ВыборкаБанков.Количество();
	
КонецФункции

////////////////////////////////////////////////////////////////////////////////
// Запись обработанных данных

///  Записывает/перезаписывает в справочник КлассификаторБанков данные банка.
// Параметры:
//	ПараметрыЗагрузкиДанных - Структура:
//	СтруктураБанк			- Структура или СтрокаТаблицыЗначений - Данные банка.
//	Загружено				- Число								 - Количество новых записей классификатора.
//	Обновлено				- Число								 - Количество обновленных записей классификатора.
//
Процедура ЗаписатьЭлементКлассификатораБанковРФ(СведенияОБанке)
	
	НачатьТранзакцию();
	Попытка
		Блокировка = Новый БлокировкаДанных;
		ЭлементБлокировки = Блокировка.Добавить("Справочник.КлассификаторБанков");
		Блокировка.Заблокировать();
		
		РегионСсылка = Справочники.КлассификаторБанков.НайтиПоКоду(СведенияОБанке.КодРегиона);
		
		Если РегионСсылка.Пустая() Тогда
			Регион = Справочники.КлассификаторБанков.СоздатьГруппу();
		Иначе
			Регион = РегионСсылка.ПолучитьОбъект();
			Если Не РегионСсылка.ЭтоГруппа Тогда 
				Регион.Код = "";
				Регион.Записать();
				Регион = Справочники.КлассификаторБанков.СоздатьГруппу();
			КонецЕсли;
		КонецЕсли;
		
		Если СокрЛП(Регион.Код) <> СокрЛП(СведенияОБанке.КодРегиона) Тогда
			Регион.Код = СокрЛП(СведенияОБанке.КодРегиона);
		КонецЕсли;
		
		Если СокрЛП(Регион.Наименование) <> СокрЛП(СведенияОБанке.Регион) Тогда
			Регион.Наименование = СокрЛП(СведенияОБанке.Регион);
		КонецЕсли;
		
		Если Регион.Модифицированность() Тогда
			Регион.Записать();
		КонецЕсли;
	
		БанкСсылка = Справочники.КлассификаторБанков.НайтиПоКоду(СведенияОБанке.БИК);
		
		Если БанкСсылка.Пустая() Тогда
			БанкОбъект = Справочники.КлассификаторБанков.СоздатьЭлемент();
		Иначе
			БанкОбъект = БанкСсылка.ПолучитьОбъект();
			Если БанкОбъект.ЭтоГруппа Тогда
				БанкОбъект.Код = "";
				БанкОбъект.Записать();
				БанкОбъект = Справочники.КлассификаторБанков.СоздатьЭлемент();
			КонецЕсли;
		КонецЕсли;
		
		Если БанкОбъект.ДеятельностьПрекращена Тогда
			БанкОбъект.ДеятельностьПрекращена = Ложь;
		КонецЕсли;

		Если БанкОбъект.Код <> СведенияОБанке.БИК Тогда
			БанкОбъект.Код = СведенияОБанке.БИК;
		КонецЕсли;

		Для Каждого Реквизит Из БанкОбъект.Метаданные().Реквизиты Цикл
			ИмяРеквизита = Реквизит.Имя;
			Если СведенияОБанке.Свойство(ИмяРеквизита) И ТипЗнч(БанкОбъект[ИмяРеквизита]) = Тип("Строка") Тогда
				ОбновитьЗначениеРеквизита(БанкОбъект, ИмяРеквизита, СведенияОБанке[ИмяРеквизита]);
			КонецЕсли;
		КонецЦикла;

		ОбновитьЗначениеРеквизита(БанкОбъект, "Наименование", СведенияОБанке.Наименование);

		Если Не ПустаяСтрока(Регион) Тогда
			Если БанкОбъект.Родитель <> Регион.Ссылка Тогда
				БанкОбъект.Родитель = Регион.Ссылка;
			КонецЕсли;
		КонецЕсли;

		Если ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
			Страна = "РФ";
			Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.КонтактнаяИнформация") Тогда
				МодульРаботаСАдресамиКлиентСервер = ОбщегоНазначения.ОбщийМодуль("РаботаСАдресамиКлиентСервер");
				Страна = МодульРаботаСАдресамиКлиентСервер.ОсновнаяСтрана();
			КонецЕсли;
			ОбновитьЗначениеРеквизита(БанкОбъект, "Страна", Страна);
		КонецЕсли;

		Если БанкОбъект.Модифицированность() Тогда
			БанкОбъект.Записать();
		КонецЕсли;
		
		ЗафиксироватьТранзакцию();
	Исключение
		ОтменитьТранзакцию();
		ВызватьИсключение;
	КонецПопытки;
	
КонецПроцедуры

Процедура ОбновитьЗначениеРеквизита(СправочникОбъект, ИмяРеквизита, Значение)
	Если СправочникОбъект[ИмяРеквизита] <> Значение Тогда
		Если ЗначениеЗаполнено(Значение) Тогда
			СправочникОбъект[ИмяРеквизита] = Значение;
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// Прочие процедуры и функции

// Определяет нужно ли обновление данных классификатора.
//
Функция КлассификаторАктуален() Экспорт
	ПоследнееОбновление = ДатаПоследнейЗагрузки();
	ДопустимаяПросрочка = 30*60*60*24;
	
	Если ТекущаяДатаСеанса() > ПоследнееОбновление + ДопустимаяПросрочка Тогда
		Возврат Ложь; // Пошла просрочка.
	КонецЕсли;
	
	Возврат Истина;
КонецФункции

Функция АктуальностьКлассификатораБанков() Экспорт
	
	ПоследнееОбновление = ДатаПоследнейЗагрузки();
	ДопустимаяПросрочка = 60*60*24;
	
	Результат = Новый Структура;
	Результат.Вставить("КлассификаторУстарел", Ложь);
	Результат.Вставить("КлассификаторПросрочен", Ложь);
	Результат.Вставить("ВеличинаПросрочкиСтрокой", "");
	
	Если ТекущаяДатаСеанса() > ПоследнееОбновление + ДопустимаяПросрочка Тогда
		Результат.ВеличинаПросрочкиСтрокой = ОбщегоНазначения.ИнтервалВремениСтрокой(ПоследнееОбновление, ТекущаяДатаСеанса());
		
		ВеличинаПросрочки = (ТекущаяДатаСеанса() - ПоследнееОбновление);
		ДнейПросрочено = Цел(ВеличинаПросрочки/60/60/24);
		
		Результат.КлассификаторУстарел = ДнейПросрочено >= 1;
		Результат.КлассификаторПросрочен = ДнейПросрочено >= 7;
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции

Функция ДатаПоследнейЗагрузки()
	Возврат СведенияОКлассификаторе().ДатаЗагрузки;
КонецФункции

Функция СведенияОКлассификаторе()
	УстановитьПривилегированныйРежим(Истина);
	Результат = Константы.ВерсияКлассификатораБанков.Получить().Получить();
	УстановитьПривилегированныйРежим(Ложь);
	Если ТипЗнч(Результат) <> Тип("Структура") Тогда
		Результат = НовоеОписаниеКлассификатора();
	КонецЕсли;
	Возврат Результат;
КонецФункции

Процедура УстановитьВерсиюКлассификатора(Знач ВерсияКлассификатора = Неопределено)
	Если Не ЗначениеЗаполнено(ВерсияКлассификатора) Тогда
		ВерсияКлассификатора = ТекущаяУниверсальнаяДата();
	КонецЕсли;
	СведенияОКлассификаторе = НовоеОписаниеКлассификатора(ВерсияКлассификатора, ТекущаяДатаСеанса());
	УстановитьПривилегированныйРежим(Истина);
	Константы.ВерсияКлассификатораБанков.Установить(Новый ХранилищеЗначения(СведенияОКлассификаторе));
	УстановитьПривилегированныйРежим(Ложь);
КонецПроцедуры

Функция НовоеОписаниеКлассификатора(ДатаМодификации = '00010101', ДатаЗагрузки = '00010101')
	Результат = Новый Структура;
	Результат.Вставить("ДатаМодификации", ДатаМодификации);
	Результат.Вставить("ДатаЗагрузки", ДатаЗагрузки);
	Возврат Результат;
КонецФункции

Функция ИдентификаторКлассификатора()
	
	Возврат "Banks";
	
КонецФункции

#КонецОбласти

#КонецЕсли