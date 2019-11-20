&НаСервере
Функция ВыполнитьЗапрос(пКод)
	Запрос=Новый Запрос;
	Запрос.Текст=
	"ВЫБРАТЬ
	|	F003Подразделения.ID_PODR,
	|	F003Подразделения.NAME_PODR,
	|	F003Подразделения.ADDR_P,
	|	F003Подразделения.TYPE_BRANCH,
	|	F003_T.NAME КАК ПГБ2_NAME_BRANCH
	|ИЗ
	|	Справочник.F003.Подразделения КАК F003Подразделения
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.F003 КАК F003
	|		ПО F003Подразделения.Ссылка = F003.Ссылка
	|		ЛЕВОЕ СОЕДИНЕНИЕ Справочник.F003_T КАК F003_T
	|		ПО F003Подразделения.TYPE_BRANCH = F003_T.ID
	|ГДЕ
	|	F003.Код = &Код";
	Запрос.УстановитьПараметр("Код",пКод);
	пРез=Запрос.Выполнить().Выгрузить();
	Возврат пРез;
КонецФункции	
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	пТЗ=ВыполнитьЗапрос(Объект.Код);
	ЭтаФорма.ТолькоПросмотр=Истина;
	ЗначениеВРеквизитФормы(пТЗ,"ТЗПодразделения");
КонецПроцедуры
