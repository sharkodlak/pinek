<?php

$di = new \Phalcon\DI\FactoryDefault();
$di->set('router', function () {
	$router = new \Phalcon\Mvc\Router();
	$router->setDefaultModule('shop');
	$router->add(
		'/:module/:controller/:action/:params',
		array(
			'module' => 1,
			'controller' => 2,
			'action' => 3,
			'params' => 4,
		)
	);
	return $router;
});
try {
	$application = new \Phalcon\Mvc\Application($di);
	$application->registerModules(
		array(
			'shop' => array(
				'className' => 'Bishop\Shop\Module',
				'path' => ROOT_DIR . '/app/shop/Module.php',
			),
			'backend'  => array(
				'className' => 'Bishop\Admin\Module',
				'path' => ROOT_DIR . '/app/admin/Module.php',
			)
		)
	);
	echo $application->handle()->getContent();
} catch (\Exception $e) {
	echo $e->getMessage();
}
