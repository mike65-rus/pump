///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ОбработчикиСобытийФормы

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	Если НЕ ПравоДоступа("Изменение", Метаданные.Справочники.ГруппыДоступа)
	     
	 ИЛИ ПараметрыДоступа("Изменение", Метаданные.Справочники.ГруппыДоступа,
	         "Ссылка").ОграничениеУсловием Тогда
		
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
	Если ОбщегоНазначения.ЭтоАвтономноеРабочееМесто() Тогда
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПриЧтенииНаСервере(ТекущийОбъект)
	
	Если ТекущийОбъект.Ссылка = Справочники.ГруппыДоступа.РодительПерсональныхГруппДоступа(Истина) Тогда
		ТолькоПросмотр = Истина;
	КонецЕсли;
	
	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПриЧтенииНаСервере(ЭтотОбъект, ТекущийОбъект);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

&НаСервере
Процедура ОбработкаПроверкиЗаполненияНаСервере(Отказ, ПроверяемыеРеквизиты)
	
	НаименованиеПерсональныхГруппДоступа = Неопределено;
	
	РодительПерсональныхГруппДоступа = Справочники.ГруппыДоступа.РодительПерсональныхГруппДоступа(
		Истина, НаименованиеПерсональныхГруппДоступа);
	
	Если Объект.Ссылка <> РодительПерсональныхГруппДоступа
	   И Объект.Наименование = НаименованиеПерсональныхГруппДоступа Тогда
		
		ОбщегоНазначения.СообщитьПользователю(
			НСтр("ru = 'Это наименование зарезервировано.'"),
			,
			"Объект.Наименование",
			,
			Отказ);
	КонецЕсли;
	
КонецПроцедуры

&НаСервере
Процедура ПослеЗаписиНаСервере(ТекущийОбъект, ПараметрыЗаписи)

	// СтандартныеПодсистемы.УправлениеДоступом
	Если ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.УправлениеДоступом") Тогда
		МодульУправлениеДоступом = ОбщегоНазначения.ОбщийМодуль("УправлениеДоступом");
		МодульУправлениеДоступом.ПослеЗаписиНаСервере(ЭтотОбъект, ТекущийОбъект, ПараметрыЗаписи);
	КонецЕсли;
	// Конец СтандартныеПодсистемы.УправлениеДоступом

КонецПроцедуры

#КонецОбласти
