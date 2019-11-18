Функция СведенияОВнешнейОбработке() Экспорт
       ДанныеДляРег = Новый Структура();
       ДанныеДляРег.Вставить("Наименование","Внешняя обработка получения НСИ с сервера СКФОМС");
       ДанныеДляРег.Вставить("Информация","Внешняя обработка СКФОМС-НСИ");
       ДанныеДляРег.Вставить("БезопасныйРежим", Ложь);
       ДанныеДляРег.Вставить("Версия", "ver.: 1.001");
       ДанныеДляРег.Вставить("Вид", "ДополнительнаяОбработка");
       ТабЗнКоманды = Новый ТаблицаЗначений;
       ТабЗнКоманды.Колонки.Добавить("Идентификатор");
       ТабЗнКоманды.Колонки.Добавить("Использование");
       ТабЗнКоманды.Колонки.Добавить("Представление");
       НовСтрока = ТабЗнКоманды.Добавить();
       НовСтрока.Идентификатор = "ВнешняяОбработкаСКФОМС_НСИ";
       НовСтрока.Использование = "ВызовСерверногоМетода";
       НовСтрока.Представление = "Внешняя обработка СКФОМС-НСИ";
       ДанныеДляРег.Вставить("Команды", ТабЗнКоманды);
       Возврат ДанныеДляРег;
КонецФункции

Процедура ВыполнитьПолучениеНСИ(ВнешняяОбработкаСсылка) 
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
	пИмяФайла=ОбщегоНазначенияПУМПСервер.ПолучитьПапкуДанных()+ПолучитьРазделительПутиСервера()+"SpravNSI";
	// Записываем картинку на диск.
    Результат.ПолучитьТелоКакДвоичныеДанные().Записать(пИмяФайла+".zip");	
	//
	Архив = Новый ЧтениеZipФайла(
		пИмяФайла,
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

Процедура ВыполнитьКоманду(ИдентификаторКоманды) Экспорт	//,ПараметрыОбработки) Экспорт
//	ВнешняяОбработкаСсылка=ПараметрыОбработки.ДополнительнаяОбработкаСсылка;
//	ХранилищеНастроек=ОбщегоНазначения.ПолучитьЗначение
	ВыполнитьПолучениеНСИ(ИдентификаторКоманды);
КонецПроцедуры	