&НаКлиенте
Перем ФормаРедактированияЗапроса Экспорт; //Хранит ссылку на форму редактора запросов
Перем Настройки;
&НаСервере
Перем ПреобразованиеДанных;

#Область ОбработчикиСобытийФормы

// Процедура - Обработчик события "ПриСозданииНаСервере" формы
//
&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ОбновитьСписокРегистров();
	
КонецПроцедуры // ПриСозданииНаСервере()

// Процедура - Обработчик события "ПередЗагрузкойДанныхИзНастроекНаСервере" формы
//
&НаСервере
Процедура ПередЗагрузкойДанныхИзНастроекНаСервере(Настройки)
	
	Если Настройки["ВыгружаемыеДвижения"] = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Для Каждого ТекЭлемент Из Настройки["ВыгружаемыеДвижения"] Цикл
		
		Если ТекЭлемент.Пометка Тогда
			Продолжить;
		КонецЕсли;
		
		ТекРегистр = ВыгружаемыеДвижения.НайтиПоЗначению(ТекЭлемент.Значение);
		
		Если ТекРегистр = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ТекРегистр.Пометка = Ложь;
		
	КонецЦикла;
	
	Настройки.Удалить("ВыгружаемыеДвижения");
	
КонецПроцедуры // ПередЗагрузкойДанныхИзНастроекНаСервере()

// Процедура - Обработчик события "ПриОткрытии" формы
//
&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ВремНомерФайла = ПолучитьНомерФайла(ПутьКФайлу);
	Если ВремНомерФайла = Неопределено Тогда
		НомерПервогоФайла = 1;
	Иначе
		НомерПервогоФайла = ВремНомерФайла;
	КонецЕсли;
	
	Настройки = ПолучитьНастройки();
	
	ПроверитьСвойства(Настройки, "ПреобразованиеДанных, ПроцессорЗапросов", "Отсутствуют обязательные настройки: %1");
	
	ПодключитьВнешнююОбработку("ПроцессорЗапросов"   , Настройки.ПроцессорЗапросов);
	ПодключитьВнешнююОбработку("ПреобразованиеДанных", Настройки.ПреобразованиеДанных);
	
	ФормаРедактированияЗапроса();
	
	ОбновитьСписокКолонокЗапроса();
	
КонецПроцедуры // ПриОткрытии()

// Процедура - Обработка оповещения формы
//
&НаКлиенте
Процедура ОбработкаОповещения(ИмяСобытия, Параметр, Источник)
	
	Если ИмяСобытия = "ИзмененыНастройки" И Параметр = ЭтаФорма Тогда
		ОбновитьСписокКолонокЗапроса();
	КонецЕсли;
	
КонецПроцедуры // ОбработкаОповещения()

#КонецОбласти

#Область ОбработчикиСобытийЭлементовФормы

// Процедура - обработка начала выбора файла
//
&НаКлиенте
Процедура ПутьКФайлуНачалоВыбора(Элемент, ДанныеВыбора, СтандартнаяОбработка)
	
	Диалог = Новый ДиалогВыбораФайла(?(Элементы.ГруппаСтраницы.ТекущаяСтраница = Элементы.ГруппаВыгрузка,
	                                   РежимДиалогаВыбораФайла.Сохранение,
									   РежимДиалогаВыбораФайла.Открытие));
									   
	Диалог.Фильтр = "Файл выгрузки / загрузки (*.json)|*.json";
	Диалог.Заголовок = "Файл выгрузки / загрузки";

	ЗавершениеВыбораФайла = Новый ОписаниеОповещения("ПутьКФайлуНачалоВыбораЗавершение", ЭтаФорма);
	
	Диалог.Показать(ЗавершениеВыбораФайла);
	
КонецПроцедуры // ПутьКФайлуНачалоВыбора()

// Процедура - продолжение обработки выбора файла
//
&НаКлиенте
Процедура ПутьКФайлуНачалоВыбораЗавершение(ВыбранныеФайлы, ДополнительныеПараметры) Экспорт
	
	Если НЕ ТипЗнч(ВыбранныеФайлы) = Тип("Массив") Тогда
		Возврат;
	КонецЕсли;
	
	Если ВыбранныеФайлы.Количество() = 0 Тогда
		Возврат;
	КонецЕсли;
	
	ПутьКФайлу = ВыбранныеФайлы[0];
	
	ВремНомерФайла = ПолучитьНомерФайла(ПутьКФайлу);
	Если ВремНомерФайла = Неопределено Тогда
		НомерПервогоФайла = 1;
	Иначе
		НомерПервогоФайла = ВремНомерФайла;
	КонецЕсли;
	
КонецПроцедуры // ПутьКФайлуНачалоВыбораЗавершение()

#КонецОбласти

#Область ПроцедурыВыгрузкиЗагрузкиДвижений

// Функция - Возвращает движения документов в формате JSON
//
// Параметры:
//  ТекущийИндекс     - Число     - индекс начального элемента списка документов для обработки
//                                  (реквизита формы СписокДокументов)
// 
// Возвращаемое значение:
//	Строка        - движения документов в формате JSON
//
&НаСервере
Функция ПолучитьДвиженияНаСервере(ТекущийИндекс)
	
	ДанныеДляСохранения = Новый Массив();
	
	Обработано = 0;
	
	// обработка списка документов начиная с указанного идекса 
	Для й = ТекущийИндекс По СписокДокументов.Количество() - 1 Цикл							 
		
		ТекЭлементДок = СписокДокументов.Получить(й);
		
		Если НЕ ТекЭлементДок.Пометка Тогда
			Продолжить;
		КонецЕсли;
			
		ДокОбъект = ТекЭлементДок.Значение.ПолучитьОбъект();
		
		// подготовка списка регистров, движения которых будут выгружены
		СписокРегистров = Новый Массив();
		
		Для Каждого ТекЭлемент Из ВыгружаемыеДвижения Цикл
			
			Если НЕ ТекЭлемент.Пометка Тогда
				Продолжить;
			КонецЕсли;
			
			СписокРегистров.Добавить(ТекЭлемент.Значение);
			
		КонецЦикла;
		
		СтруктураДвижений = ПреобразованиеДанных().ДвиженияДокументаВСтруктуру(ДокОбъект, СписокРегистров);
		
		ДанныеДокумента = Новый Структура("Ссылка, Движения", ПреобразованиеДанных().ЗначениеВСтруктуру(ДокОбъект.Ссылка), СтруктураДвижений);
		
		ДанныеДляСохранения.Добавить(ДанныеДокумента);
		
		Обработано = Обработано + 1;
		
		// отсечка по количеству объектов в одном файле
		Если КоличествоДокументовВФайле > 0 И Обработано >= КоличествоДокументовВФайле Тогда
			Прервать;
		КонецЕсли;
		
	КонецЦикла;
	
	ТекущийИндекс = й;
		
	Возврат ПреобразованиеДанных().ЗаписатьОписаниеОбъектаВJSON(ДанныеДляСохранения);
	
КонецФункции // ПолучитьДвиженияНаСервере()

// Процедура - Выполняет загрузку движений документов
//
// Параметры:
//  ДанныеСтрокой         - Строка        - движения документов в формате JSON
//
&НаСервере
Процедура ЗагрузитьДвиженияНаСервере(ДанныеСтрокой)
	
	ДанныеДляЗагрузки = ПреобразованиеДанных().ПрочитатьОписаниеОбъектаИзJSON(ДанныеСтрокой);
	
	Для Каждого ТекДокумент Из ДанныеДляЗагрузки Цикл
		
		ДокСсылка = ПреобразованиеДанных().ЗначениеИзСтруктуры(ТекДокумент.Ссылка);
		
		Если ДокСсылка = Неопределено Тогда
			Продолжить;
		КонецЕсли;
		
		ДокОбъект = ДокСсылка.ПолучитьОбъект();
		
		ПреобразованиеДанных().ДвиженияДокументаИзСтруктуры(ДокОбъект, ТекДокумент.Движения);
		
		Для Каждого ТекНабор Из ТекДокумент.Движения Цикл
			Попытка
				ДокОбъект.Движения[ТекНабор.Ключ].ОбменДанными.Загрузка = Истина;
				ДокОбъект.Движения[ТекНабор.Ключ].Записать();
			Исключение
				ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
				ТекстСообщения = "Не удалось записать движения документа """ + СокрЛП(ДокСсылка) + """: " + Символы.ПС;
				Сообщить(ТекстСообщения + ТекстОшибки);
			КонецПопытки;
		КонецЦикла;
		
	КонецЦикла;
	
КонецПроцедуры // ЗагрузитьДвиженияНаСервере()

#КонецОбласти

#Область ОбработкаКоманд

// Процедура - Заполняет список документов по указанным настройкам процессора запрососв
//
// Параметры:
//  НастройкиПолученияДанных   - Структура           - настройки процессора запросов
//		*Запрос_Текст               - Строка              - текст запроса
//		*Запрос_Параметры           - Массив (Структура)  - таблица параметров запроса
//		*ПроизвольныеВыражения      - Массив (Структура)  - таблица произвольных функций
//
&НаСервере
Процедура ЗаполнитьСписокДокументовНаСервере(НастройкиПолученияДанных)
	
	СписокДокументов.Очистить();
	
	ТекстОшибки = "";
	
	Попытка
		РезультатЗапроса = ПроцессорЗапросов().ВыполнитьЗапрос(НастройкиПолученияДанных.Запрос_Текст
															, ПреобразованиеДанных().ЗначениеИзСтруктуры(НастройкиПолученияДанных.Запрос_Параметры)
															, 
															, ПреобразованиеДанных().ЗначениеИзСтруктуры(НастройкиПолученияДанных.ПроизвольныеВыражения)
															, 
															, Ложь
															, ТекстОшибки);
	Исключение
		ТекстОшибки = "Ошибка запроса 1С: ";
		ТекстОшибки = ТекстОшибки + Символы.ПС + ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		ВызватьИсключение ТекстОшибки;
	КонецПопытки;
		
	Если НЕ ПустаяСтрока(ТекстОшибки) Тогда
		ТекстОшибки = "Ошибка запроса 1С: " + ТекстОшибки;
		ВызватьИсключение ТекстОшибки;
	КонецЕсли;
		
	Если РезультатЗапроса.Пустой() Тогда
		Сообщить("Запрос не вернул результатов!");
		Возврат;
	КонецЕсли;
		
	Выборка = РезультатЗапроса.Выбрать();
	
	Пока Выборка.Следующий() Цикл
		ТекСсылка = СписокДокументов.ТипЗначения.ПривестиЗначение(Выборка[КолонкаЗапроса]);
		Если НЕ ЗначениеЗаполнено(ТекСсылка) Тогда
			Продолжить;
		КонецЕсли;
		СписокДокументов.Добавить(Выборка[КолонкаЗапроса]);
	КонецЦикла;
		
КонецПроцедуры // ЗаполнитьСписокДокументовНаСервере()

// Процедура - Обработчик команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗаполнитьСписокДокументов(Команда)
	
	НастройкиПолученияДанных = ФормаРедактированияЗапроса().ПолучитьЗапросСПараметрами();

	ЗаполнитьСписокДокументовНаСервере(НастройкиПолученияДанных);
	
КонецПроцедуры // ЗаполнитьСписокДокументов()

// Процедура - Обработчик команды команды "СохранитьДвижения"
//
&НаКлиенте
Процедура СохранитьДвижения(Команда)
	
	СчетчикФайлов = НомерПервогоФайла;
	
	ТекущийИндекс = 0;
	
	Пока ТекущийИндекс <= СписокДокументов.Количество() - 1 Цикл
		
		ВремФайл = Новый Файл(ПутьКФайлу);
		
		ИмяФайла = ВремФайл.Путь + ПолучитьИмяФайлаБезНомера(ПутьКФайлу) + Формат(СчетчикФайлов, "ЧГ=0") + ВремФайл.Расширение;
		
		ДанныеДляСохранения = ПолучитьДвиженияНаСервере(ТекущийИндекс);
	
		Текст = Новый ТекстовыйДокумент();
		Текст.УстановитьТекст(ДанныеДляСохранения);
		Текст.НачатьЗапись(, ИмяФайла, "UTF-8");
	
		СчетчикФайлов = СчетчикФайлов + 1;
		
		ТекущийИндекс = ТекущийИндекс + 1;
		
	КонецЦикла;
	
КонецПроцедуры // СохранитьДвижения()

// Процедура - Обработчик команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗагрузитьДвижения(Команда)
	
	СчетчикФайлов = НомерПервогоФайла;
	
	ВремФайл = Новый Файл(ПутьКФайлу);
	Путь = ВремФайл.Путь;
	Имя = ПолучитьИмяФайлаБезНомера(ВремФайл);
	
	Пока Истина Цикл
		ТекПутьКФайлу = Путь + Имя + Формат(СчетчикФайлов, "ЧГ=0") + ВремФайл.Расширение;
		
		ВремФайл = Новый Файл(ТекПутьКФайлу);
		
		Если НЕ ВремФайл.Существует() Тогда
			Прервать;
		КонецЕсли;
		
		ДопПараметры = Новый Структура("ТекстДанных, ПутьКФайлу", Новый ТекстовыйДокумент(), ТекПутьКФайлу);
	
		ОбработкаЧтенияФайла = Новый ОписаниеОповещения("ЗагрузитьДвиженияЗавершение", ЭтотОбъект, ДопПараметры);
	
		ДопПараметры.ТекстДанных.НачатьЧтение(ОбработкаЧтенияФайла, ТекПутьКФайлу, "UTF-8");
	
		СчетчикФайлов = СчетчикФайлов + 1;
	КонецЦикла;	
	
КонецПроцедуры // ЗагрузитьДвижения()

// Процедура - Завершение обработки команды команды "ЗагрузитьДвижения"
//
&НаКлиенте
Процедура ЗагрузитьДвиженияЗавершение(ДополнительныеПараметры) Экспорт
	
	ЗагрузитьДвиженияНаСервере(ДополнительныеПараметры.ТекстДанных.ПолучитьТекст());
	
КонецПроцедуры // ЗагрузитьДвиженияЗавершение()

// Процедура - Обработчик команды "РедактироватьЗапрос" - открывает редактор запроса
//
&НаКлиенте
Процедура РедактироватьЗапрос(Команда)
	
	ФормаРедактированияЗапроса().Открыть();
	
КонецПроцедуры //РедактироватьЗапрос()

#КонецОбласти

#Область СлужебныеПроцедуры

// Функция - возвращает настройки из JSON-файла настроек
//
// Параметры:
//  АдресНастроек     - Строка     - адрес временного хранилища настроек
// 
// Возвращаемое значение:
//	Структура      - полученные настройки
//
&НаСервере
Функция ПолучитьНастройкиНаСервере(Знач АдресНастроек)
	
	ДанныеНастроек = ПолучитьИзВременногоХранилища(АдресНастроек);
	
	ЧтениеНастроек = Новый ЧтениеJSON();

	ЧтениеНастроек.ОткрытьПоток(ДанныеНастроек.ОткрытьПотокДляЧтения());
	
	Возврат ПрочитатьJSON(ЧтениеНастроек, Ложь, , ФорматДатыJSON.ISO);
	
КонецФункции // ПолучитьНастройкиНаСервере()

// Функция - возвращает настройки из JSON-файла настроек
//
// Параметры:
//  ПутьКФайлуНастроек     - Строка     - путь к JSON-файлу настроек
// 
// Возвращаемое значение:
//	Структура      - полученные настройки
//
&НаКлиенте
Функция ПолучитьНастройки(Знач ПутьКФайлуНастроек = "")
	
	Если НЕ ЗначениеЗаполнено(ПутьКФайлуНастроек) Тогда
		ПутьКФайлуНастроек = КаталогТекущейОбработки() + "settings.json";
	КонецЕсли;
	
	ПроверитьДопустимостьТипа(ПутьКФайлуНастроек,
	                          "Строка, Файл",
	                          СтрШаблон("Некорректно указан файл настроек ""%1""", СокрЛП(ПутьКФайлуНастроек)) +
							  ", тип ""%1"", ожидается тип %2!");
	
	Если ТипЗнч(ПутьКФайлуНастроек) = Тип("Файл") Тогда
		ПутьКФайлуНастроек = ПутьКФайлуНастроек.ПолноеИмя;
	КонецЕсли;
	
	АдресНастроек = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ПутьКФайлуНастроек), ЭтотОбъект.УникальныйИдентификатор);
	
	Попытка
		Возврат ПолучитьНастройкиНаСервере(АдресНастроек);
	Исключение
		ВызватьИсключение СтрШаблон("Ошибка чтения файла настроек ""%1"": %2%3",
		                            ПутьКФайлуНастроек,
									Символы.ПС,
									ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
	КонецПопытки;
	
КонецФункции // ПолучитьНастройки()

// Функция - возвращает путь к каталогу текущей обработки
// 
// Возвращаемое значение:
//	Строка       - путь к каталогу текущей обработки
//
&НаСервере
Функция КаталогТекущейОбработки()
	
	ОбработкаОбъект = РеквизитФормыВЗначение("Объект");
	
	ФайлЭтойОбработки = Новый Файл(ОбработкаОбъект.ИспользуемоеИмяФайла);
	
	Возврат ФайлЭтойОбработки.Путь;
	
КонецФункции // КаталогТекущейОбработки()

// Функция - Получает обработку процессора запросов
// 
// Возвращаемое значение:
//		ВнешняяОбработкаОбъект - обработка процессора запросов
//
&НаСервере
Функция ПроцессорЗапросов() Экспорт
	
	Возврат ВнешниеОбработки.Создать("ПроцессорЗапросов");
	
КонецФункции // ПроцессорЗапросов()

// Функция - Получает форму редактирования запросов
// 
// Возвращаемое значение:
//		УправляемаяФорма - Форма редактирования запроса
//
&НаКлиенте
Функция ФормаРедактированияЗапроса() Экспорт
	
	Если ФормаРедактированияЗапроса = Неопределено Тогда
		//@skip-warning
		ФормаРедактированияЗапроса = ПолучитьФорму("ВнешняяОбработка.ПроцессорЗапросов.Форма.Форма", , ЭтаФорма);
	КонецЕсли;
	
	Возврат ФормаРедактированияЗапроса;
	
КонецФункции // ФормаРедактированияЗапроса()

// Функция - Получает обработку сериализации значений
// 
// Возвращаемое значение:
//		ВнешняяОбработкаОбъект - обработка преобразования данных
//
&НаСервере
Функция ПреобразованиеДанных() Экспорт
	
	Если ПреобразованиеДанных = Неопределено Тогда
		ПреобразованиеДанных = ВнешниеОбработки.Создать("ПреобразованиеДанных");
	КонецЕсли;
	 
	Возврат ПреобразованиеДанных; 
	
КонецФункции // ПреобразованиеДанных()

// Функция - ищет внешнюю обработку по указанному имени и пути, подключает ее
// и возвращает имя подключенной обработки
//
// Параметры:
//  ИмяОбработки         - Строка        - имя внешней обработки
// 
// Возвращаемое значение:
//  ВнешняяОбработкаОбъект        - внешняя обработка
// 
&НаКлиенте
Функция ПодключитьВнешнююОбработку(Знач ИмяОбработки, Знач ПутьКОбработке = "")
	
	Если ЗначениеЗаполнено(ПутьКОбработке) Тогда
		ПутьКОбработке = СтрЗаменить(ПутьКОбработке, "$thisRoot\", КаталогТекущейОбработки());
	Иначе
		ПутьКОбработке = КаталогТекущейОбработки() + ИмяОбработки + ".epf";
	КонецЕсли;
	
	АдресОбработки = ПоместитьВоВременноеХранилище(Новый ДвоичныеДанные(ПутьКОбработке), ЭтотОбъект.УникальныйИдентификатор);
	
	Возврат ПодключитьВнешнююОбработкуНаСервере(АдресОбработки, ИмяОбработки);
	
КонецФункции // ПодключитьВнешнююОбработкуПоИмени()

// Функция - подключает внешнюю обработку из указанного хранилища с указанным именем
// возвращает имя подключенной обработки
//
// Параметры:
//  ИмяОбработки         - Строка        - имя внешней обработки
// 
// Возвращаемое значение:
//  ВнешняяОбработкаОбъект        - внешняя обработка
// 
&НаСервере
Функция ПодключитьВнешнююОбработкуНаСервере(Знач АдресОбработки, Знач ИмяОбработки = "")
	
	ОписаниеЗащиты = Новый ОписаниеЗащитыОтОпасныхДействий();
	ОписаниеЗащиты.ПредупреждатьОбОпасныхДействиях = Ложь;
	
	Возврат ВнешниеОбработки.Подключить(АдресОбработки, ИмяОбработки, Ложь, ОписаниеЗащиты);
	
КонецФункции // ПодключитьВнешнююОбработкуНаСервере()

// Процедура - Обновляет список колонок запроса для выбора
//
&НаКлиенте
Процедура ОбновитьСписокКолонокЗапроса()
	
	Элементы.КолонкаЗапроса.СписокВыбора.Очистить();
	
	КолонкиЗапроса = ФормаРедактированияЗапроса().ПолучитьКолонкиЗапроса();
	
	Для Каждого ТекКолонка Из КолонкиЗапроса Цикл
		Элементы.КолонкаЗапроса.СписокВыбора.Добавить(ТекКолонка.Имя);
	КонецЦикла;
	
КонецПроцедуры // ОбновитьСписокКолонокЗапроса()

// Процедура - Обновляет список выгружаемых регистров
//
&НаСервере
Процедура ОбновитьСписокРегистров()
	
	ВыгружаемыеДвижения.Очистить();
	
	Для Каждого ТекРегистр Из Метаданные.РегистрыСведений Цикл
		Если ТекРегистр.РежимЗаписи = Метаданные.СвойстваОбъектов.РежимЗаписиРегистра.Независимый Тогда
			Продолжить;
		КонецЕсли;
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр сведений: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыНакопления Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр накопления: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыБухгалтерии Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр бухгалтерии: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	Для Каждого ТекРегистр Из Метаданные.РегистрыРасчета Цикл
		ВыгружаемыеДвижения.Добавить(ТекРегистр.Имя, "Регистр расчета: " + ТекРегистр.Представление(), Истина);
	КонецЦикла;
		
	ВыгружаемыеДвижения.СортироватьПоПредставлению();
	
КонецПроцедуры // ОбновитьСписокРегистров()

// Функция - Возвращает завершающую, цифровую часть имени файла (расширение не учитывается)
//
// Параметры:
//  ПутьКФайлу         - Строка, Файл     - путь к файлу или файл для получения номера
// 
// Возвращаемое значение:
//   Число, Неопределено    - номер файла, (Неопределено - имя файла оканчивается не на цифру)
//
&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьНомерФайла(Знач ПутьКФайлу)
	
	ИмяФайла = "";
	Если ТипЗнч(ПутьКФайлу) = Тип("Файл") Тогда
		ИмяФайла = ИмяФайла.ИмяБезРасширения;
	Иначе
		ВремФайл = Новый Файл(ПутьКФайлу);
		ИмяФайла = ВремФайл.ИмяБезРасширения;
	КонецЕсли;
	
	НомерФайла  = "";
	
	НомерСимвола = СтрДлина(ВремФайл.ИмяБезРасширения);
		
	Пока Истина Цикл
		
		Если НомерСимвола = 0 Тогда
			Прервать;
		КонецЕсли;
		
		ТекСимвол = Сред(ИмяФайла, НомерСимвола, 1);
		Если Найти("0123456789", ТекСимвол) = 0 Тогда
			Прервать;
		КонецЕсли;
		
		НомерФайла = ТекСимвол + НомерФайла;
		
		НомерСимвола = НомерСимвола - 1;
		
	КонецЦикла;
	
	Если ПустаяСтрока(НомерФайла) Тогда
		Возврат Неопределено;
	КонецЕсли;
	
	Попытка
		Возврат Число(НомерФайла);
	Исключение
		Возврат Неопределено;
	КонецПопытки;
	
КонецФункции // ПолучитьНомерФайла()

// Функция - Возвращает имя файла без завершающей, цифровой части (расширение не учитывается)
//
// Параметры:
//  ПутьКФайлу         - Строка, Файл     - путь к файлу или файл для получения имени
// 
// Возвращаемое значение:
//   Строка    - имя файла без завершающих цифр
//
&НаКлиентеНаСервереБезКонтекста
Функция ПолучитьИмяФайлаБезНомера(Знач ПутьКФайлу)
	
	ИмяФайла = "";
	Если ТипЗнч(ПутьКФайлу) = Тип("Файл") Тогда
		ИмяФайла = ПутьКФайлу.ИмяБезРасширения;
	Иначе
		ВремФайл = Новый Файл(ПутьКФайлу);
		ИмяФайла = ВремФайл.ИмяБезРасширения;
	КонецЕсли;
	
	НомерФайла = ПолучитьНомерФайла(ИмяФайла);
	
	Если НомерФайла = Неопределено Тогда
		Возврат ИмяФайла;
	Иначе
		Возврат Сред(ИмяФайла, 1, СтрДлина(ИмяФайла) - СтрДлина(Формат(НомерФайла, "ЧГ=0")));
	КонецЕсли;
	
КонецФункции // ПолучитьИмяФайлаБезНомера()

// Функция - проверяет тип значения на соответствие допустимым типам
//
// Параметры:
//  Значение             - Произвольный                 - проверяемое значение
//  ДопустимыеТипы       - Строка, Массив(Строка, Тип)  - список допустимых типов
//  ШаблонТекстаОшибки   - Строка                       - шаблон строки сообщения об ошибке
//                                                        ("Некорректный тип значения ""%1"" ожидается тип %2")
// 
// Возвращаемое значение:
//	Булево       - Истина - проверка прошла успешно
//
Функция ПроверитьДопустимостьТипа(Знач Значение, Знач ДопустимыеТипы, Знач ШаблонТекстаОшибки = "")
	
	ТипЗначения = ТипЗнч(Значение);
	
	Если ТипЗнч(ДопустимыеТипы) = Тип("Строка") Тогда
		МассивДопустимыхТипов = СтрРазделить(ДопустимыеТипы, ",");
	ИначеЕсли ТипЗнч(ДопустимыеТипы) = Тип("Массив") Тогда
		МассивДопустимыхТипов = ДопустимыеТипы;
	Иначе
		ВызватьИсключение СтрШаблон("Некорректно указан список допустимых типов, тип ""%1"" ожидается тип %2!",
		                            Тип(ДопустимыеТипы),
									"""Строка"" или ""Массив""");
	КонецЕсли;
	
	Типы = Новый Соответствие();
	
	СтрокаДопустимыхТипов = "";
	
	Для Каждого ТекТип Из МассивДопустимыхТипов Цикл
		ВремТип = ?(ТипЗнч(ТекТип) = Тип("Строка"), Тип(СокрЛП(ТекТип)), ТекТип);
		Типы.Вставить(ВремТип, СокрЛП(ТекТип));
		СтрокаДопустимыхТипов = СтрокаДопустимыхТипов
		                      + ?(СтрокаДопустимыхТипов = "",
							      "",
							      ?(МассивДопустимыхТипов.Найти(ТекТип) = МассивДопустимыхТипов.ВГраница(),
								    " или ",
								    ", "))
		                      + """" + СокрЛП(ТекТип) + """";
	КонецЦикла;
	
	Если ШаблонТекстаОшибки = "" Тогда
		ШаблонТекстаОшибки = "Некорректный тип значения ""%1"" ожидается тип %2!";
	КонецЕсли;
	
	Если Типы[ТипЗначения] = Неопределено Тогда
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, СокрЛП(ТипЗначения), СтрокаДопустимыхТипов);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьДопустимостьТипа()

// Функция - Проверить свойства
//
// Параметры:
//  ПроверяемаяСтруктура     - Структура               - проверяемая структура
//  ОбязательныеСвойства     - Строка, Массив(Строка)  - список обязательных свойств
//  ШаблонТекстаОшибки       - Строка                  - шаблон строки сообщения об ошибке
//                                                       ("Отсутствуют обязательные свойства: %1")
// 
// Возвращаемое значение:
//	Булево       - Истина - проверка прошла успешно
//
Функция ПроверитьСвойства(Знач ПроверяемаяСтруктура, Знач ОбязательныеСвойства, Знач ШаблонТекстаОшибки = "")
	
	ПроверитьДопустимостьТипа(ОбязательныеСвойства,
	                          "Строка, Массив",
	                          "Некорректно указан список обязательных свойств, тип ""%1"", ожидается тип %2!");
							  
	Если ТипЗнч(ОбязательныеСвойства) = Тип("Строка") Тогда
		МассивСвойств = СтрРазделить(ОбязательныеСвойства, ",");
	ИначеЕсли ТипЗнч(ОбязательныеСвойства) = Тип("Массив") Тогда
		МассивСвойств = ОбязательныеСвойства;
	КонецЕсли;
	
	СтрокаСвойств = "";
	
	Для Каждого ТекСвойство Из МассивСвойств Цикл
		
		Если ПроверяемаяСтруктура.Свойство(СокрЛП(ТекСвойство)) Тогда
			Продолжить;
		КонецЕсли;
		
		СтрокаСвойств = СтрокаСвойств
		                      + ?(СтрокаСвойств = "", Символы.ПС, ", " + Символы.ПС)
		                      + """" + СокрЛП(ТекСвойство) + """";
	КонецЦикла;
						  
	Если ШаблонТекстаОшибки = "" Тогда
		ШаблонТекстаОшибки = "Отсутствуют обязательные свойства: %1";
	КонецЕсли;
	
	Если НЕ СтрокаСвойств = "" Тогда
		ВызватьИсключение СтрШаблон(ШаблонТекстаОшибки, СтрокаСвойств);
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции // ПроверитьСвойства()

#КонецОбласти

