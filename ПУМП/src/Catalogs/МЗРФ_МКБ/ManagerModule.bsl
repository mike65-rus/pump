#Если Сервер Или ТолстыйКлиентОбычноеПриложение Или ВнешнееСоединение Тогда

Процедура УдалитьВременныеФайлы(пМассивУдаляемыхФайлов)
	Попытка
		УдалитьФайлы(пМассивУдаляемыхФайлов);
	Исключение
	КонецПопытки;	
КонецПроцедуры	
	
Процедура ВыполнитьЗагрузкуИзФайла(Данные) Экспорт
	Перем ИмяХмлФайла,ИмяПдфФайла,МассивУдаляемыхФайлов;

	// Получение имени временного файла
	ИмяВременногоФайла = ПолучитьИмяВременногоФайла("zip");
	// Сохранение данных во временный файл
	Данные.Записать(ИмяВременногоФайла);
	
	МассивУдаляемыхФайлов=Новый Массив;
	МассивУдаляемыхФайлов.Добавить(ИмяВременногоФайла);
	// Обработка файла…
	Архив = Новый ЧтениеZipФайла(
		ИмяВременногоФайла,
        "" // пароль к архиву
    );	
    Для Каждого Элемент Из Архив.Элементы Цикл
		ОбщегоНазначения.СообщитьПользователю(
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Извлечение файла %1 из архива %2'"),Элемент.Имя,ИмяВременногоФайла ));
	    	
        Архив.Извлечь(
            Элемент, // элемент для извлечения
            КаталогВременныхФайлов(),
            РежимВосстановленияПутейФайловZIP.НеВосстанавливать,
            "" // пароль
        );
        МассивУдаляемыхФайлов.Добавить(КаталогВременныхФайлов()+Элемент.Имя);
        Если Прав(НРЕГ(Элемент.Имя),4)=".xml" Тогда
        	ИмяХмлФайла=Элемент.Имя;
        КонецЕсли;	
        Если Прав(НРЕГ(Элемент.Имя),4)=".pdf" Тогда
        	ИмяПдфФайла=Элемент.Имя;
        КонецЕсли;	
	КонецЦикла; 
	Архив.Закрыть();

	Если ИмяХмлФайла=Неопределено Тогда
		УдалитьВременныеФайлы(МассивУдаляемыхФайлов);
		ВызватьИсключение СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'Ошибка: в архиве %1 нет файла типа XML'"), ИмяВременногоФайла);
	КонецЕсли;
	
	пСправочник=Справочники.МЗРФ_МКБ;

	Парсер = Новый ЧтениеXML;
    Парсер.ОткрытьФайл(КаталогВременныхФайлов()+ИмяХмлФайла);
    Построитель = Новый ПостроительDOM;
    Документ = Построитель.Прочитать(Парсер);
	РазименовывателиПИ = Документ.СоздатьРазыменовательПИ(Документ);	       
	Запрос="count(/book/entries/entry)";
	Путь=Документ.СоздатьВыражениеXPath(Запрос,РазименовывателиПИ);
	Результат = Путь.Вычислить(Документ);
	ВсегоЭлементов=Результат.ЧисловоеЗначение;
	ОбщегоНазначения.СообщитьПользователю(
		СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = 'В файле %1 %2 элемента'"),Элемент.Имя,ВсегоЭлементов));
	ДельтаСообщений=Цел(ВсегоЭлементов/100);
	Запрос="/book/entries/entry";
	Путь=Документ.СоздатьВыражениеXPath(Запрос,РазименовывателиПИ);
	Результат = Путь.Вычислить(Документ);
	пСпис=Новый СписокЗначений;
	Эл=Результат.ПолучитьСледующий();
	СчетчикЭлементов=0;
	Пока Эл<>Неопределено Цикл
//		пСпис.Добавить(Эл.ЗначениеУзла,Эл.ЗначениеУзла , , );
		СчетчикЭлементов=СчетчикЭлементов+1;
		Если (СчетчикЭлементов % ДельтаСообщений=0) Тогда
			Если 1=2 Тогда
			ОбщегоНазначения.СообщитьПользователю(
			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Обработано %1 элементов из %2'"),СчетчикЭлементов,ВсегоЭлементов));
			КонецЕсли;	
		КонецЕсли;
		пСпис=Новый СписокЗначений;
		Для Каждого Эл2 ИЗ Эл.ДочерниеУзлы Цикл
			пСпис.Добавить(Эл2.ИмяУзла,Эл2.ТекстовоеСодержимое);
		КонецЦикла;
			
		пНаименование=пСпис.НайтиПоЗначению("MKB_NAME").Представление;
		пИД=пСпис.НайтиПоЗначению("ID").Представление;
		пЭлСписД=пСпис.НайтиПоЗначению("DATE");
		Если пЭлСписД=Неопределено Тогда
			пДатаАкт="";
		Иначе
			пДатаАкт=пЭлСписД.Представление;
		КонецЕсли;
		пЭлСписПарент=пСпис.НайтиПоЗначению("ID_PARENT");
		Если пЭлСписПарент=Неопределено Тогда
			пИДПарент="0";
		Иначе
			пИДПарент=пЭлСписПарент.Представление;
		КонецЕсли;
		
		пАктуал=пСпис.НайтиПоЗначению("ACTUAL").Представление;
		пРекКод=пСпис.НайтиПоЗначению("REC_CODE").Представление;
		пЭлСписАддл=пСпис.НайтиПоЗначению("ADDL_CODE");
		Если пЭлСписАддл=Неопределено Тогда
			пАддл="0";
		Иначе
			пАддл=пЭлСписАддл.Представление;
		КонецЕсли;	
		пЭлСпис=пСпис.НайтиПоЗначению("MKB_CODE");
		Если пЭлСпис=Неопределено Тогда
			пЭтоГруппа=Истина;
			пКод="";
			пКодСпр=Прав(пНаименование,9);
			пКодСпр=СтрЗаменить(пКодСпр,"(","");
			пКодСпр=СтрЗаменить(пКодСпр,")","");
//			ОбщегоНазначения.СообщитьПользователю(
//			СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
//				НСтр("ru = 'Найдена группа %1'"),пНаименование));
		Иначе
			пКод=пСпис.НайтиПоЗначению("MKB_CODE").Представление;
			пЭтоГруппа=Истина;
			Если СтрДлина(пКод)=3 Тогда
				Запрос2="/book/entries/entry/ID_PARENT[text()='"+пИД+"']"+
					"/parent::entry/ACTUAL[text()='1']";
				Запрос2="count("+Запрос2+")";
	        	Путь2=Документ.СоздатьВыражениеXPath(Запрос2,РазименовывателиПИ);
				Результат2 = Путь2.Вычислить(Документ);
				Если Результат2.ЧисловоеЗначение=0 Тогда
//					ОбщегоНазначения.СообщитьПользователю(
//					СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
//						НСтр("ru = 'Найден простой код %1'"),пКод));
					пЭтоГруппа=Ложь;		
//					ОбщегоНазначения.СообщитьПользователю(
//							СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
//							НСтр("ru = 'Найден одинокий код %1'"),пКод));
				КонецЕсли;		
			КонецЕсли;	
		КонецЕсли;
		// 
		пСпрСсылка=пСправочник.НайтиПоКоду(пКодСпр);
		Если пСпрСсылка.Пустая() Тогда
			Если пЭтоГруппа Тогда
				пОбъектСправочника=пСправочник.СоздатьГруппу();
			Иначе
				пОбъектСправочника=пСправочник.СоздатьЭлемент();				
			КонецЕсли;
		Иначе
			пОбъектСправочника=пСпрСсылка.ПолучитьОбъект();	
		КонецЕсли;	
		Если Число(пИДПарент)<>0 Тогда
			пСпрСсылкаРодитель=пСправочник.НайтиПоРеквизиту("ID",Число(пИДПарент));
			Если пСпрСсылкаРодитель.Пустая() Тогда
				пОбъектСправочника.Родитель=Неопределено;
			Иначе
				пОбъектСправочника.Родитель=пСпрСсылкаРодитель;
				Если пСпрСсылкаРодитель.ЭтоГруппа=Ложь Тогда
					пОбъектСправочника.Родитель=пСпрСсылкаРодитель.Родитель;
				КонецЕсли;	
			КонецЕсли;
		Иначе
			пОбъектСправочника.Родитель=Неопределено;
		КонецЕсли;		
		пОбъектСправочника.Код=пКодСпр;
		пОбъектСправочника.Наименование=пНаименование;
		пОбъектСправочника.MKB_CODE=пКод;
		пОбъектСправочника.MKB_NAME=пНаименование;
		пОбъектСправочника.ID=Число(пИД);
		пОбъектСправочника.PARENT_ID=Число(пИДПарент);
		пОбъектСправочника.REC_CODE=пРекКод;
		пОбъектСправочника.ADDL_CODE=Число(пАктуал);
		пОбъектСправочника.ACTUAL=Число(пАддл);
		пОбъектСправочника.DATA=ОбщегоНазначенияПГБ2.STODRus(пДатаАкт);


		Эл=Результат.ПолучитьСледующий();
		
	КонецЦикла;
	Парсер.Закрыть();
	
	Соединение = Новый HTTPСоединение(
        "tfomssk.ru", // сервер (хост)
        443, // порт, по умолчанию для http используется 80, для https 443
        , // пользователь для доступа к серверу (если он есть)
        , // пароль для доступа к серверу (если он есть)
        , // здесь указывается прокси, если он есть
        , // таймаут в секундах, 0 или пусто - не устанавливать
       Новый ЗащищенноеСоединениеOpenSSL()
    );
	// Get-запрос к ресурсу на сервере.
    Запрос = Новый HTTPЗапрос("/files/nsi/SpravNSI.zip");
    Результат = Соединение.Получить(Запрос);	
	
	// Хорошим тоном будет удалить временный файл
	УдалитьВременныеФайлы(МассивУдаляемыхФайлов);
КонецПроцедуры

#КонецЕсли