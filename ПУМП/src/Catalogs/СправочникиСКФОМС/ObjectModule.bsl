//Предопределенная процедура
Процедура ПередЗаписью(Отказ)
	ЕстьВМетаданных=Метаданные.Справочники.Найти(Код);
	Если ЕстьВМетаданных=Неопределено Тогда
		ЗагружаетсяВСистему=Ложь;
	Иначе
		ЗагружаетсяВСистему=Истина;
	КонецЕсли;
КонецПроцедуры