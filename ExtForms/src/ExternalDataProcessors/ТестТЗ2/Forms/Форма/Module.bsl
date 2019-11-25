&НаКлиенте
Перем МассивСервера;
&НаКлиенте
Процедура ВыполнитьОбновление()
	пСтруктураСервера=ОбновитьНаСервере();
	МассивСервера=пСтруктураСервера.МассивПациентов;
	Объект.ДатаОбновленияСтационар=пСтруктураСервера.ДатаФайла1;
	Объект.ДатаОбновленияДневнойСтационар=пСтруктураСервера.ДатаФайла2;
КонецПроцедуры	
&НаКлиенте
Процедура Обновить(Команда)
	// Вставить содержимое обработчика.
	ВыполнитьОбновление();
	ОбновитьТЗ();
КонецПроцедуры
&НаСервереБезКонтекста
Функция ВернутьПутьКФайлу()
	Перем пПуть;
	Если ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		пПуть="d:\educ";
	ИначеЕсли ОбщегоНазначения.ЭтоLinuxСервер() Тогда
		пПуть="/home/pharma/share/eir2";
	КонецЕсли;	
	Возврат пПуть;
КонецФункции	
&НаСервереБезКонтекста
Функция ПреобразоватьСтроковуюДатуВДату(пСтрЗнач)
	Перем пДата;
	Попытка
		пДата=Дата(Число(Лев(пСтрЗнач,4)),
			 Число(Сред(пСтрЗнач,6,2)),
			 Число(Прав(пСтрЗнач,2)));
	Исключение
		пДата=Неопределено;		 
	КонецПопытки;
	Возврат пДата;
КонецФункции	
&НаСервереБезКонтекста
Функция ПреобразоватьСтроковоеЗначение(пИмяУзла,пСтрЗнач)
	пРез=пСтрЗнач;
	пРеквизитыТипаДата="DNGOSP,DNAPR,DPGOSP,";
	Если СтрНайти(пРеквизитыТипаДата,пИмяУзла+",")>0 Тогда
		пРез=ПреобразоватьСтроковуюДатуВДату(пСтрЗнач);
	КонецЕсли;	
	Возврат пРез;
КонецФункции	
&НаСервереБезКонтекста
Функция ЗаполнитьСтруктуру(Эл,пСтрокаСтруктуры)
	СтрСтруктура=Новый Структура(пСтрокаСтруктуры);
	Для Каждого Элемент0 Из Эл.ДочерниеУзлы Цикл
		пИмяУзла=Элемент0.ИмяУзла;
		Если СтрНайти(пСтрокаСтруктуры+",",пИмяУзла+",")>0 Тогда
			СтрЗнач=Элемент0.ТекстовоеСодержимое;
			СтрСтруктура[пИмяУзла]=ПреобразоватьСтроковоеЗначение(пИмяУзла,СтрЗнач);
		КонецЕсли;	
	КонецЦикла;	
	Возврат СтрСтруктура;
КонецФункции	
&НаСервереБезКонтекста
Функция ПолучитьПоляДляСтруктуры(Эл)
	Перем пРез;
	пРез="";
	Для Каждого Элемент0 Из Эл.ДочерниеУзлы Цикл
		пИмяУзла=Элемент0.ИмяУзла;
		пРез=пРез+пИмяУзла+",";
	КонецЦикла;
	пРез=пРез+"НомСтр,ВидСтационара";
	Возврат пРез;
КонецФункции	
&НаСервереБезКонтекста
Процедура ПрочитатьФайлНаСервере(пФайл,пМассив)
	Перем пСч,Парсер,Построитель,Документ,пПоляДляСтруктуры,пНоваяСтруктура;
	Парсер = Новый ЧтениеXML;
    Парсер.ОткрытьФайл(пФайл);
 
    Построитель = Новый ПостроительDOM;
 	
    Документ = Построитель.Прочитать(Парсер);
	пСч=1;
 	Для Каждого Элемент0 Из Документ.ЭлементДокумента.ДочерниеУзлы Цикл
        Если Элемент0.ИмяУзла = "ZAP" Тогда
            Эл = Элемент0;	
			Если пСч=1 Тогда
				пПоляДляСтруктуры=ПолучитьПоляДляСтруктуры(Эл);
			КонецЕсли;
			пНоваяСтруктура=ЗаполнитьСтруктуру(Эл,пПоляДляСтруктуры);
			пНоваяСтруктура.НомСтр=пМассив.Количество();
			пНоваяСтруктура.ВидСтационара=?(СтрНайти(пФайл,"_D.")>0,2,1);
			пМассив.Добавить(пНоваяСтруктура);
			пСч=пСч+1;
		КонецЕсли;	
	КонецЦикла;
	Парсер.Закрыть();
КонецПроцедуры
&НаСервереБезКонтекста
Функция ОбновитьНаСервере()
	Перем пВозвращаемаяСтруктура;
	Перем пМассив;
	Перем пМассивФайлов,пФайл,ш;
	пВозвращаемаяСтруктура=Новый Структура("ДатаФайла1,ДатаФайла2,МассивПациентов");
	пВозвращаемаяСтруктура.ДатаФайла1=Неопределено;
	пВозвращаемаяСтруктура.ДатаФайла2=Неопределено;
	пВозвращаемаяСтруктура.МассивПациентов=Новый Массив;
	пМассивФайлов=Новый Массив;
	пМассивФайлов.Добавить("all_planed.xml");
	пМассивФайлов.Добавить("ALL_planed_D.XML");
	пМассив=Новый Массив;
	Для ш=0 По пМассивФайлов.Количество()-1 Цикл
		пФайл=ВернутьПутьКФайлу()+ПолучитьРазделительПутиСервера()+пМассивФайлов[ш];
		пВыбФайл=Новый Файл(пФайл);
		Если пВыбФайл.Существует()=Истина Тогда
			пВозвращаемаяСтруктура["ДатаФайла"+Строка(ш+1)]=пВыбФайл.ПолучитьВремяИзменения();			
			ПрочитатьФайлНаСервере(пФайл,пМассив);
		КонецЕсли;	
	КонецЦикла;	
	пВозвращаемаяСтруктура.МассивПациентов=пМассив;
	Возврат пВозвращаемаяСтруктура;
КонецФункции	

&НаКлиенте
Процедура ПриОткрытии(Отказ)
	ВыполнитьОбновление();
	Объект.Подразделение=238;
	Объект.ВидСтационара=1;	// круглосут
	Объект.ВыбраннаяДата=ТекущаяДата();
	ВыбраннаяДатаПриИзменении(Элементы.ВыбраннаяДата);
КонецПроцедуры

&НаКлиенте
Процедура ВыбраннаяДатаПриИзменении(Элемент)
	// Вставить содержимое обработчика.
	ПриИзмененииДаты();
КонецПроцедуры
&НаКлиенте
Процедура ПриИзмененииДаты()
	ОбновитьТЗ();
КонецПроцедуры
&НаКлиенте
Функция ФамилияИмяОтчество(пФам,пИм,пОт)
	Перем пРез;
	пРез="";
	пРез=СОКРЛП(?(пФам=Неопределено,"",пФам));
	пРез=пРез+" "+СОКРЛП(?(пИм=Неопределено,"",пИм));
	пРез=пРез+" "+СОКРЛП(?(пОт=Неопределено,"",пОт));
	Возврат СОКРЛП(пРез);
КонецФункции	
&НаКлиенте
Процедура ОбновитьТЗ()
	// Сначала сделать сортировку в списке значений, чтобы избежать серверного вызова для ТЗ.Сортировать!!!
	пСпис=Новый СписокЗначений;
	пМассив=МассивСервера;
	пПодразделение=Объект.Подразделение;
	пВидСтационара=Объект.ВидСтационара;
	ш2=пМассив.Количество();
	Для ш=0 По ш2-1 Цикл
		Если Число(пМассив[ш].PMO)<>пПодразделение Тогда
			Продолжить;
		КонецЕсли;	
		Если пМассив[ш].ВидСтационара<>пВидСтационара Тогда
			Продолжить;
		КонецЕсли;	
		Если пМассив[ш].DPGOSP=Объект.ВыбраннаяДата   Тогда
			пСпис.Добавить(ш,ФамилияИмяОтчество(пМассив[ш].FAM,пМассив[ш].IM,пМассив[ш].OT));
		КонецЕсли;	
	КонецЦикла;				
	пСпис.СортироватьПоПредставлению(НаправлениеСортировки.Возр);	// Сортировка по ФИО
	
	
//	Элементы.ТЗ.ОтборСтрок=Неопределено;
//	Элементы.ТЗ.Обновить();
	пДоступность=Элементы.ТЗ.КоманднаяПанель.ПодчиненныеЭлементы.ТЗОтменитьПоиск.Доступность;
	// Заполнение ТЗ в порядке отсортированного по ФИО списка значений
	пТЗ=Объект.ТЗ;
	пТЗ.Очистить();
	Для Каждого Эл ИЗ пСпис Цикл
		СтрТаб=пТЗ.Добавить();
		ш=Число(Эл.Значение);
		СтрТаб.ФИО=Эл.Представление;
		СтрТаб.ИндексМассива=ш;
		СтрТаб.ДатаНачалаГоспитализации=пМассив[ш].DPGOSP;
		СтрТаб.ДатаНаправления=пМассив[ш].DNAPR;
		СтрТаб.Подразделение=пМассив[ш].PMO;
	КонецЦикла;	
	ЭтаФорма.ТекущийЭлемент=Элементы.ТЗ;
//	пТЗ.Сортировать("ФИО");	// Это приводит к вызову сервера во всех режисах клиента !!!
КонецПроцедуры	

&НаКлиенте
Процедура ПроизвестиВыбор()
	ТекДанные = Элементы.ТЗ.ТекущиеДанные;
	Если ТекДанные = Неопределено Тогда 
		Возврат; 
	КонецЕсли; 
	ш=ТекДанные.ИндексМассива;
	пМассив=МассивСервера;
	пФИО=ФамилияИмяОтчество(пМассив[ш].FAM,пМассив[ш].IM,пМассив[ш].OT);
	Сообщить(пФИО+" ПОЛИС: "+пМассив[ш].NPOLIS+" НАПРАВЛЕНИЕ: "+пМассив[ш].NNAPR);
КонецПроцедуры

&НаКлиенте
Процедура ТЗВыборЗначения(Элемент, Значение, СтандартнаяОбработка)
	ПроизвестиВыбор();
КонецПроцедуры


&НаКлиенте
Процедура ПодразделениеПриИзменении(Элемент)
	// Вставить содержимое обработчика.
	Если Объект.Подразделение<>238 Тогда
		Объект.ВидСтационара=2;	// дневной
	КонецЕсли;	
	ОбновитьТЗ();
КонецПроцедуры


&НаКлиенте
Процедура ВидСтационараПриИзменении(Элемент)
	// Вставить содержимое обработчика.
	ОбновитьТЗ();
КонецПроцедуры

&НаСервереБезКонтекста
Процедура ПолучитьФайлНСИНаСервере()
	пИмяФайла=ОбщегоНазначенияПУМПСервер.ПолучитьПапкуДанных()+ПолучитьРазделительПутиСервера()+"SpravNSI";
	// Записываем картинку на диск.
//    Результат.ПолучитьТелоКакДвоичныеДанные().Записать(пИмяФайла);	
	//
	Архив = Новый ЧтениеZipФайла(
		пИмяФайла+".zip",
        "" // пароль к архиву
    );	
 // Распакуем файлы по одиночке.    
    Для Каждого Элемент Из Архив.Элементы Цикл
        Архив.Извлечь(
            Элемент, // элемент для извлечения
            пИмяФайла,
            РежимВосстановленияПутейФайловZIP.НеВосстанавливать,
            "" // пароль
        );
	КонецЦикла; 
	Архив.Закрыть();

КонецПроцедуры
//Параметры: пЗн-Строка, пТип-Тип
&НаСервереБезКонтекста
Функция ЗначениеXmlВЗначение(пЗн,пТип)
	Перем пРез;
	пРез=Неопределено;
	Если Строка(пТип)="Дата" Тогда
		пРез=ОбщегоНазначенияПГБ2.STOD(пЗн,Истина);
	КонецЕсли;	
	Если Строка(пТип)="Число" Тогда
		пРез=Число(пЗн);
	КонецЕсли;
	Если Строка(пТип)="Строка" Тогда
		пРез=СтрЗаменить(пЗн,"&quot;","""");		
	КонецЕсли;
	Возврат пРез;
КонецФункции

&НаСервереБезКонтекста
Функция ПостроитьПолныйПуть(СтекИмен)
    Путь = "";
    Для Каждого Имя Из СтекИмен Цикл
        Путь = Путь + "/" + Имя;
    КонецЦикла;
    Возврат Путь;
КонецФункции
&НаСервереБезКонтекста
Функция УзелВСтеке(пПуть,СтекИмен)
	Перем пРет;
	пРет=Ложь;
	Для Каждого Эл Из СтекИмен Цикл
		Если СтрНайти(Эл.Значение,пПуть)>0 Тогда
			пРет=Истина;
			Возврат пРет; 
		КонецЕсли;	
	КонецЦикла;		
	Возврат пРет; 
КонецФункции
	
&НаСервереБезКонтекста
Процедура ЗагрузитьV001Справочник()
	пПапкаНСИ="D:\educ\STORAGE";
	пИмяСправочника="V001";
	пВключаемыеКоды="A,B,S,";
	пНеВключаемыеКоды="A.,B.,";
	ИмяПоляИД="ID";	
	ИмяПоляДатаНач="DATEBEG";	
	ИмяПоляНаименование="NAME";
	пФайл=пПапкаНСИ+ПолучитьРазделительПутиСервера()+пИмяСправочника+".xml";
	пСпрМенеджер=Справочники[пИмяСправочника];
	пСтруктураСправочника=Новый Структура;
	Для Каждого Реквизит Из Метаданные.Справочники[пИмяСправочника].Реквизиты Цикл
		ИмяРеквизита=Реквизит.Имя;
		//Сообщить(ИмяРеквизита);
		пТип=Реквизит.Тип;
		пСтруктураСправочника.Вставить(ИмяРеквизита,пТип);
	КонецЦикла;	
	Парсер = Новый ЧтениеXML;
    Парсер.ОткрытьФайл(пФайл);
    СтекИмен = Новый СписокЗначений;
	Пока Парсер.Прочитать() Цикл
		 Если Парсер.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		 	Если Не УзелВСтеке("/"+Парсер.Имя,СтекИмен) Тогда
		        СтекИмен.Добавить(Парсер.Имя);
		 	КонецЕсли;	
	        ПолныйПуть = ПостроитьПолныйПуть(СтекИмен);
            Если ПолныйПуть = "/NOMECLRLIST/item" Тогда
            	пНужноЗаписать=Ложь;
				пСтруктураАтрибутов=Новый Структура;
				пСтруктураНовыхЗначенийСправочника=Новый Структура;
				Пока Парсер.ПрочитатьАтрибут() Цикл
					пИмяАтрибута=ВРЕГ(Парсер.Имя);
					Если пИмяАтрибута="СОEMZDR" Тогда
						// Костыль - первые 2 символа в xml русские - ужас от ТФОМС!
						пИмяАтрибута="COEMZDR";
					КонецЕсли;	
					пЗначениеАтрибута=Парсер.Значение;
					пСтруктураАтрибутов.Вставить(пИмяАтрибута,пЗначениеАтрибута);
				КонецЦикла;
	        	Для Каждого ЭлАтр ИЗ пСтруктураАтрибутов Цикл
	        		пТип=Неопределено;
	        		пНайдено=пСтруктураСправочника.Свойство(ЭлАтр.Ключ,пТип);
	        		Если НЕ пНайдено Тогда
	        			Продолжить;
	        		Иначе
	       				пСтруктураНовыхЗначенийСправочника.Вставить(
	       					ЭлАтр.Ключ,
	       					ЗначениеXmlВЗначение(ЭлАтр.Значение,пТип));
		    		КонецЕсли;	
	        	КонецЦикла;
	        	пЗнИД=Неопределено;
	        	пНайдено1=пСтруктураАтрибутов.Свойство(ИмяПоляИД,пЗнИД);
	        	Если Не пНайдено1 Тогда
	        		Продолжить;
	        	ИначеЕсли СтрНайти(пВключаемыеКоды,Лев(пЗнИД,1)+",")=0 Тогда	
	        		Продолжить;
	        	ИначеЕсли СтрНайти(пНеВключаемыеКоды,Лев(пЗнИД,2)+",")=1 Тогда	
	        		Продолжить;
	        	КонецЕсли;
	        	пЗнДатаНач=Неопределено;
	        	пНайдено1=пСтруктураАтрибутов.Свойство(ИмяПоляДатаНач,пЗнДатаНач);
	        	Если Не пНайдено1 Тогда
	        		Продолжить;
	        	Иначе
	        		Если пЗнДатаНач="" Тогда
	        			Продолжить;
	        		КонецЕсли;	
	        	КонецЕсли;
				пКод=СОКРЛП(пЗнИД)+"-"+
    	    		ОбщегоНазначенияПГБ2.DTOS(ОбщегоНазначенияПГБ2.STOD(пЗнДатаНач,Истина));
        		пНайденныйЭлемент=пСпрМенеджер.НайтиПоКоду(пКод);
	   	    	пНужноЗаписать=Истина;
	   	    	//@skip-warning
	   	    	пНовый=НЕ ЗначениеЗаполнено(пНайденныйЭлемент);
				Если Не пНовый Тогда
					пНайденныйОбъект=пНайденныйЭлемент.ПолучитьОбъект();
		 			пНужноЗаписать=Ложь;
					Для Каждого пЗн ИЗ пСтруктураНовыхЗначенийСправочника Цикл
						Если НЕ (пЗн.Значение=пНайденныйОбъект[пЗн.Ключ]) Тогда
							пНужноЗаписать=Истина;
							пНайденныйОбъект[пЗн.Ключ]=пЗн.Значение;
							Прервать;
						КонецЕсли	
					КонецЦикла;	
				Иначе
					пНужноЗаписать=Истина;	
					пНайденныйОбъект=Справочники[пИмяСправочника].СоздатьЭлемент();
					Для Каждого пЗн ИЗ пСтруктураНовыхЗначенийСправочника Цикл
						пНайденныйОбъект[пЗн.Ключ]=пЗн.Значение;
						Если пЗн.Ключ=ИмяПоляНаименование Тогда
							Попытка
								пНайденныйОбъект.Наименование=пЗн.Значение;
							Исключение
							КонецПопытки;
						КонецЕсли;	
					КонецЦикла;	
				КонецЕсли;	        	
	//			Если (пНужноЗаписать И (НЕ пНовый)) Тогда
//					пНайденныйОбъект.Должности.Очистить();
//					пНайденныйОбъект.Профили.Очистить();
//				КонецЕсли;	
            ИначеЕсли ПолныйПуть= "/NOMECLRLIST/item/DOLGLIST" Тогда
					пНайденныйОбъект.Должности.Очистить();
            ИначеЕсли ПолныйПуть= "/NOMECLRLIST/item/PROFLIST" Тогда
					пНайденныйОбъект.Профили.Очистить();
            ИначеЕсли ПолныйПуть = "/NOMECLRLIST/item/DOLGLIST/item1" Тогда
            	DOLGNOST=Парсер.ЗначениеАтрибута("DOLGNOST");
            	Если DOLGNOST<>Неопределено Тогда
            		пНужноЗаписать=Истина;
            		DATE_BEG=ЗначениеXmlВЗначение(Парсер.ЗначениеАтрибута("DATE_BEG"),Тип("Дата"));
            		DATE_END=ЗначениеXmlВЗначение(Парсер.ЗначениеАтрибута("DATE_END"),Тип("Дата"));
            		НоваяСтрока=пНайденныйОбъект.Должности.Добавить();
            		НоваяСтрока.DOLGNOST=Число(DOLGNOST);
            		НоваяСтрока.DATE_BEG=DATE_BEG;
            		НоваяСтрока.DATE_END=DATE_END;
            	КонецЕсли;	
            ИначеЕсли ПолныйПуть = "/NOMECLRLIST/item/PROFLIST/item2" Тогда
            	PROFMEDHELP=Парсер.ЗначениеАтрибута("PROFMEDHELP");
            	Если PROFMEDHELP<>Неопределено Тогда
            		пНужноЗаписать=Истина;
            		DATE_BEG=ЗначениеXmlВЗначение(Парсер.ЗначениеАтрибута("DATE_BEG"),Тип("Дата"));
            		DATE_END=ЗначениеXmlВЗначение(Парсер.ЗначениеАтрибута("DATE_END"),Тип("Дата"));
            		НоваяСтрока=пНайденныйОбъект.Профили.Добавить();
            		НоваяСтрока.PROFMEDHELP=Число(PROFMEDHELP);
            		НоваяСтрока.DATE_BEG=DATE_BEG;
            		НоваяСтрока.DATE_END=DATE_END;
            	КонецЕсли;	
            КонецЕсли;
            
		 ИначеЕсли Парсер.ТипУзла = ТипУзлаXML.КонецЭлемента Тогда
			 Если ПолныйПуть = "/NOMECLRLIST/item" Тогда
			 	Если пНужноЗаписать Тогда
			 		пНайденныйОбъект.Записать();
			 	КонецЕсли;
			 КонецЕсли;			 	
	         СтекИмен.Удалить(СтекИмен.Количество() - 1);
             ПолныйПуть = ПостроитьПолныйПуть(СтекИмен);
	     КонецЕсли;		  
	КонецЦикла;     	
	Парсер.Закрыть();
КонецПроцедуры	
&НаСервереБезКонтекста
Процедура ЗагрузитьПростойСправочник(пИмяСправочника,ИмяПоляИД="ID",ИмяПоляДатаНач="DATE_BEG",ИмяПоляДатаКон="DATE_END")
	пПапкаНСИ="D:\educ\STORAGE";
	пФайл=пПапкаНСИ+ПолучитьРазделительПутиСервера()+пИмяСправочника+".xml";
	пСпрМенеджер=Справочники[пИмяСправочника];
	пДлинаИд=Метаданные.Справочники[пИмяСправочника].Реквизиты[ИмяПоляИД].Тип.КвалификаторыЧисла.Разрядность;
	пСтруктураСправочника=Новый Структура;
	Для Каждого Реквизит Из Метаданные.Справочники[пИмяСправочника].Реквизиты Цикл
		ИмяРеквизита=Реквизит.Имя;
		//Сообщить(ИмяРеквизита);
		пТип=Реквизит.Тип;
		пСтруктураСправочника.Вставить(ИмяРеквизита,пТип);
	КонецЦикла;	
	Парсер = Новый ЧтениеXML;
    Парсер.ОткрытьФайл(пФайл);
    Построитель = Новый ПостроительDOM;
    Документ = Построитель.Прочитать(Парсер);
 	Для Каждого Элемент0 Из Документ.ЭлементДокумента.ДочерниеУзлы Цикл
        Если Элемент0.ИмяУзла = "item" Тогда
			пСтруктура=Новый Структура;
			пСтруктураНовыхЗначенийСправочника=Новый Структура;
	        пАтрибуты=Элемент0.Атрибуты;
        	Для Каждого пАтрибут ИЗ пАтрибуты Цикл
				пИмяАтрибута=ВРЕГ(пАтрибут.Имя);
				пЗначениеАтрибута=пАтрибут.Значение;
				пСтруктура.Вставить(пИмяАтрибута,пЗначениеАтрибута);
        	КонецЦикла;
        	Для Каждого ЭлАтр ИЗ пСтруктура Цикл
        		пТип=Неопределено;
        		пНайдено=пСтруктураСправочника.Свойство(ЭлАтр.Ключ,пТип);
        		Если НЕ пНайдено Тогда
        			Продолжить;
        		Иначе
       				пСтруктураНовыхЗначенийСправочника.Вставить(
       					ЭлАтр.Ключ,
       					ЗначениеXmlВЗначение(ЭлАтр.Значение,пТип));
	    		КонецЕсли;	
        	КонецЦикла;
        	пЗнИД=Неопределено;
        	пНайдено1=пСтруктура.Свойство(ИмяПоляИД,пЗнИД);
        	Если Не пНайдено1 Тогда
        		Продолжить;
        	КонецЕсли;
        	пЗнДатаНач=Неопределено;
        	пНайдено1=пСтруктура.Свойство(ИмяПоляДатаНач,пЗнДатаНач);
        	Если Не пНайдено1 Тогда
        		Продолжить;
        	КонецЕсли;
			пКод=ОбщегоНазначенияПГБ2.StrZero(Число(пЗнИД),пДлинаИД)+"-"+
        		ОбщегоНазначенияПГБ2.DTOS(ОбщегоНазначенияПГБ2.STOD(пЗнДатаНач,Истина));
        	пНайденныйЭлемент=пСпрМенеджер.НайтиПоКоду(пКод);
   	    	пНужноЗаписать=Истина;
   	    	//@skip-warning
   	    	пНовый=НЕ ЗначениеЗаполнено(пНайденныйЭлемент);
			Если Не пНовый Тогда
				пНайденныйЭлемент=пНайденныйЭлемент.ПолучитьОбъект();
	 			пНужноЗаписать=Ложь;
				Для Каждого пЗн ИЗ пСтруктураНовыхЗначенийСправочника Цикл
					Если НЕ (пЗн.Значение=пНайденныйЭлемент[пЗн.Ключ]) Тогда
						пНужноЗаписать=Истина;
						пНайденныйЭлемент[пЗн.Ключ]=пЗн.Значение;
						Прервать;
					КонецЕсли	
				КонецЦикла;	
			Иначе
				пНужноЗаписать=Истина;	
				пНайденныйЭлемент=Справочники[пИмяСправочника].СоздатьЭлемент();
				Для Каждого пЗн ИЗ пСтруктураНовыхЗначенийСправочника Цикл
					пНайденныйЭлемент[пЗн.Ключ]=пЗн.Значение;
					Если пЗн.Ключ="NAME" Тогда
						Попытка
							пНайденныйЭлемент.Наименование=пЗн.Значение;
						Исключение
						КонецПопытки;
					КонецЕсли;	
				КонецЦикла;	
			КонецЕсли;	        	
			Если пНужноЗаписать Тогда
				пНайденныйЭлемент.Записать();        		       			
			КонецЕсли;	
     	КонецЕсли;	
	КонецЦикла;
	Парсер.Закрыть();
КонецПроцедуры
&НаСервереБезКонтекста
Процедура ВыполнитьЗагрузкуНСИ()
//	пПапкаНСИ=ОбщегоНазначенияПУМПСервер.ПолучитьПапкуДанных()+ПолучитьРазделительПутиСервера()+"STORAGE";
	// ЗагрузитьПростойСправочник("V004_D");
	ЗагрузитьV001Справочник();	
КонецПроцедуры

&НаКлиенте
Процедура ПолучитьНСИ(Команда)
	//ПолучитьФайлНСИНаСервере();
	ВыполнитьЗагрузкуНСИ();
КонецПроцедуры

