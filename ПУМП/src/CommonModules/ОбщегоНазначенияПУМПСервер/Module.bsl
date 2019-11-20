Функция ПолучитьПапкуДанных() Экспорт
	Перем пПапка;
	пПапка="";
	Если ОбщегоНазначения.ЭтоWindowsСервер() Тогда
		пПапка=СОКРЛП(Справочники.НастройкиПУМП.ПапкаWindows.Значение);
	ИначеЕсли ОбщегоНазначения.ЭтоLinuxСервер() Тогда
		пПапка=СОКРЛП(Справочники.НастройкиПУМП.ПапкаLinux.Значение);
	КонецЕсли;
	Возврат пПапка;
КонецФункции
//
// Параметры: ЭтотОбъект ОбъектТипаСправочникЭлемент 
//Варианты вызова: Присваивает код и датуСоздания/Изменения Вызывается перед записью из модуля объект справочника
Процедура ПередЗаписьюПростогоЭлементаСправочникаНСИ(ЭтотОбъект) Экспорт
	пДлинаИд=ЭтотОбъект.Метаданные().Реквизиты["ID"].Тип.КвалификаторыЧисла.Разрядность;
	пНовый=ЭтотОбъект.ЭтоНовый();
	пКод=ОбщегоНазначенияПГБ2.StrZero(ЭтотОбъект.ID,пДлинаИд);
	Если (Не (ЭтотОбъект.DATE_BEG=Неопределено)) Тогда
		пКод=пКод+"-"+ОбщегоНазначенияПГБ2.DTOS(ЭтотОбъект.DATE_BEG);
	КонецЕсли;	
	ЭтотОбъект.Код=пКод;
	Если пНовый Тогда
		ЭтотОбъект.ДатаСоздания=ТекущаяДата();
		ЭтотОбъект.ДатаИзменения=ЭтотОбъект.ДатаСоздания;
	Иначе
		ЭтотОбъект.ДатаИзменения=ТекущаяДата();
	КонецЕсли;	
КонецПроцедуры
//Параметры: Список-Список типа динамический список, пПолеОтбора - строка напр DATE_END
Процедура УстановитьУсловноеФорматированиеВСпискеНСИ(Список,пПолеОтбора) Экспорт
	Попытка
	    ЭлементОформления = Список.УсловноеОформление.Элементы.Добавить();     
	    ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	    ЭлементОтбора.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных(пПолеОтбора);   
	    ЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.Заполнено;    
	    ЭлементОтбора.ПравоеЗначение = Истина;
	    ЭлементОтбора.Использование  = Истина;
	    //
	    ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
	    ЭлементОтбора.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных(пПолеОтбора);   
	    ЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.МеньшеИлиРавно;    
	    ЭлементОтбора.ПравоеЗначение = ТекущаяДата();
	    ЭлементОтбора.Использование  = Истина;
	    //
	    ЭлементОформления.Оформление.УстановитьЗначениеПараметра("ЦветТекста", WebЦвета.РозовоКоричневый);
		ЭлементОформления.Представление = "СозданПрограммно";	    
	Исключение
	КонецПопытки;			
	
КонецПроцедуры

