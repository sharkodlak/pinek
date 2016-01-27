<?php

namespace Bishop\Shop;

class Module implements \Phalcon\Mvc\ModuleDefinitionInterface {
	public function registerAutoloaders(\Phalcon\DiInterface $di = NULL) {
		$loader = new \Phalcon\Loader();
		$loader->registerNamespaces(
			array(
				'Bishop\Shop\Controllers' => ROOT_DIR . '/app/shop/controllers/',
				'Bishop\Shop\Models' => ROOT_DIR . '/app/shop/models/',
			)
		);
		$loader->register();
	}

	public function registerServices(\Phalcon\DiInterface $di) {
		// Registering a dispatcher
		$di->set('dispatcher', function () {
			$dispatcher = new \Phalcon\Mvc\Dispatcher();
			$dispatcher->setDefaultNamespace('Bishop\Shop\Controllers');
			return $dispatcher;
		});
		// Registering the view component
		$di->set('view', function () {
			$view = new \Phalcon\Mvc\View();
			$view->setViewsDir(ROOT_DIR . '/app/shop/views/');
			return $view;
		});
	}
}