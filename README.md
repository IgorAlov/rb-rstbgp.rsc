
## Описание:

**Привет**, как известно в RouterOS, по крайней мере в 6ой версии, существует :bug:  с середины 2017 года, который, заключается в том, что время от времени рабочие BGP сессии переходят в состояние `OpenSent` или `Idle` без какой либо причины. Это очень сильно портит жизнь адимнам. Так как у разработчкиов RoS  по всей видимости нет времени, чтобы исправить этот баг, предлагаю воспользоватся даннрым скриптом, который позволяет автоматьически "передергивать" bgp сессии.

## Как установить?
Есть несколько вариантов, если вас устраивают параметры, которые заданы в скрипте по умолчанию, то вы можете прямо с github загрузить скрипты себе на роутер (при наличии интернета на нем). А если нет интрнета, то можете разместить сервер в локальной сети, и файлик скрипта уже тащить уже внутри сети, ну или просто скропировать через буфер обмена.
* Установить прямо на рутоер с репозитория можно командой: `/tool fetch url=https://ваш-www-сервер/rb-rstbgp.rsc mode=https ascii=yes keep-result=yes`, а после сохранения скрипта произвести импорт его: ``/import rb-rstbgp.rsc``
* Устновка на локальный сревер:
   * Загрузить скрипт к себе на локальный сервер можно комнадой `git clone https://github.com/IgorAlov/rb-rstbgp.rsc` в директорию вашего `www` сервера;
   * Выполняете команду на руотере для загрузки скрипта:
      * пример, если Вы используете на вашем сервере https + basic auth:
         * `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=https ascii=yes keep-result=yes user="user" password="password"`
      * пример, для простого http:
         * `/tool fetch url=https://ваш-www-сервер/rb-setfw.rsc mode=http ascii=yes keep-result=yes`
   * Импортируем загруженный скрипт `/import rb-setfw.rsc`
* Скрипт, после выполнения, должен сам удалится с устройства, однако если Вы хотите его отсавить, то можно закомментировать последню строчку в скрипте `/file remove`

## Для тех кто использует RouterOS API:
Скрипт, при использовании API, можно загрузить на роутер, и запустить примерно такой конструкцией на PHP:
```php
...
microtik_import_apiscript($API,"rb-rstbgp.rsc");
...

function	microtik_import_apiscript($API,$script_name)
	{
	if(!isset($API)||$script_name=="") return false;

	$script_id="";
	$arrID=$API->comm("/tool/fetch", 
		array(
			"mode"					=> "https",
        	"check-certificate"  => "no",
        	"url"						=> "https://ваш-www-сервер/".$script_name,
			"dst-path"				=> $script_name,
			"keep-result"			=> "yes",
			"ascii"					=> "yes",
			"user"					=> "username",
			"password"				=> "password"
			));
	sleep(2);
	$arrID=$API->comm("/file/getall", 
		array(
			".proplist"=> ".id",
			"?name"		=> $script_name
			));
	$script_id=(isset($arrID["0"][".id"]))?$arrID["0"][".id"]:"";
	if($script_id!="")
		{
		$arrID=$API->comm("/import", 
	  		array(
				"file-name"		=> $script_name
				));
	
		$arrID=$API->comm("/file/remove", 
			array(
		  	".id"		=> $script_id
		  	));
		}
   return true;
	}
```

### Описание переменных:

* `timecheck  "10m"` **->** время через которое будет вызван скрипт проверки состяния сессий (по умолчанию 10m).

* `timerst  "1s"` **->** время на которое опускается BGP сессия (по умолчанию 1s).

## Ошибки и контрибьюция
Если Вы нашли баг, или что то хотие добавить - создате `issue` я постарюсь решить его. Так же если Вы хотите стать частью проекта, то wellcome).