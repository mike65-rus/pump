
&НаСервереБезКонтекста
Процедура ВыделитьГруппыПолужирнымШрифтом(Список) 
    ЭлементОформления = Список.УсловноеОформление.Элементы.Добавить(); 
    ЭлементОтбора = ЭлементОформления.Отбор.Элементы.Добавить(Тип("ЭлементОтбораКомпоновкиДанных"));
    ЭлементОтбора.ЛевоеЗначение  = Новый ПолеКомпоновкиДанных("IS_GROUP");   
    ЭлементОтбора.ВидСравнения   = ВидСравненияКомпоновкиДанных.Больше;    
    ЭлементОтбора.ПравоеЗначение = 0;
    ЭлементОтбора.Использование  = Истина;
	ЭлементОтбора.РежимОтображения = РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ;

	ЖирныйШрифт=Новый Шрифт(,,Истина);
	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Шрифт",ЖирныйШрифт);
//	ЭлементОформления.Оформление.УстановитьЗначениеПараметра("Шрифт",Новый Шрифт(WindowsШрифты.ШрифтДиалоговИМеню,,,Истина,,,));
//	ЭлементОформления.Представление = "СозданПрограммно";

	ЭлементОформления.РежимОтображения= РежимОтображенияЭлементаНастройкиКомпоновкиДанных.БыстрыйДоступ;
	ЭлементОформления.ИдентификаторПользовательскойНастройки="IS_GROUP";
КонецПроцедуры	
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	ОбщегоНазначенияПУМПСервер.УстановитьУсловноеФорматированиеВСпискеНСИ(Список);
	// выделение групп
	Попытка
		ВыделитьГруппыПолужирнымШрифтом(Список);
	Исключение
	КонецПопытки;			
	
	
КонецПроцедуры
