<?php

class FailTest extends PHPUnit_Framework_TestCase {
	public function testFail() {
		$this->assertEquals(0, 1);
	}
}
