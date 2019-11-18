///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2019, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции
////////////////////////////////////////////////////////////////////////////////
// Обработчики операций

Функция Ping()
	Возврат "";
КонецФункции

Функция ПроверкаПодключения(СообщениеОбОшибке)
	
	СообщениеОбОшибке = "";
	
	// Проверяем наличие прав для выполнения обмена.
	Попытка
		ОбменДаннымиСлужебный.ПроверитьВозможностьВыполненияОбменов();
	Исключение
		СообщениеОбОшибке = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Ложь;
	КонецПопытки;
	
	// Проверяем блокировку информационной базы для обновления.
	Попытка
		ОбменДаннымиСлужебный.ПроверитьБлокировкуИнформационнойБазыДляОбновления();
	Исключение
		СообщениеОбОшибке = КраткоеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Ложь;
	КонецПопытки;
	
	Возврат Истина;
	
КонецФункции

Функция ПолучитьРезультатЗагрузкиДанных(ИдентификаторФоновогоЗадания, СообщениеОбОшибке)
	
	Возврат ОбменДаннымиСлужебный.ПолучитьСтатусВыполненияПолученияДанных(ИдентификаторФоновогоЗадания, СообщениеОбОшибке);
	
КонецФункции

// PutFilePart
//
Функция ЗагрузитьЧастьФайла(ИдентификаторФайла, НомерЗагружаемойЧастиФайла, ЗагружаемаяЧастьФайла, СообщениеОбОшибке)
	
	Возврат ОбменДаннымиСлужебный.ЗагрузитьЧастьФайла(ИдентификаторФайла, НомерЗагружаемойЧастиФайла, ЗагружаемаяЧастьФайла, СообщениеОбОшибке);
	
КонецФункции

// PutData
//
Функция ЗагрузитьДанныеВИнформационнуюБазу(ИдентификаторФайла, ИдентификаторФоновогоЗадания, СообщениеОбОшибке)
	
	СообщениеОбОшибке = "";
	
	СтруктураПараметров = ОбменДаннымиСлужебный.ИнициализироватьПараметрыWebСервиса();
	СтруктураПараметров.ИдентификаторФайлаВоВременномХранилище = ОбменДаннымиСлужебный.ПодготовитьФайлДляЗагрузки(ИдентификаторФайла, СообщениеОбОшибке);
	СтруктураПараметров.ИмяWEBСервиса                          = "EnterpriseDataUpload_1_0_1_1";
	
	// Загружаем в информационную базу.
	ПараметрыПроцедуры = Новый Структура;
	ПараметрыПроцедуры.Вставить("ПараметрыWEBСервиса", СтруктураПараметров);
	ПараметрыПроцедуры.Вставить("СообщениеОбОшибке",   СообщениеОбОшибке);

	ПараметрыВыполнения = ДлительныеОперации.ПараметрыВыполненияВФоне(Новый УникальныйИдентификатор);
	ПараметрыВыполнения.НаименованиеФоновогоЗадания = НСтр("ru = 'Загрузка данных в информационную базу через web-сервис ""Enterprise Data Upload""'");
	ПараметрыВыполнения.КлючФоновогоЗадания = Строка(Новый УникальныйИдентификатор);
	
	ПараметрыВыполнения.ЗапуститьВФоне = Истина;

	ФоновоеЗадание = ДлительныеОперации.ВыполнитьВФоне(
		"ОбменДаннымиСлужебный.ЗагрузитьДанныеXDTOВИнформационнуюБазу",
		ПараметрыПроцедуры,
		ПараметрыВыполнения);
	ИдентификаторФоновогоЗадания = Строка(ФоновоеЗадание.ИдентификаторЗадания);
	
	Возврат "";
	
КонецФункции

#КонецОбласти