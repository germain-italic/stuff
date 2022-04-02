<?php
if ( !(in_array(@$_SERVER['REMOTE_ADDR'], array('127.0.0.1', '::1'), true)  ) ) {
    header('HTTP/1.0 404 Not found.');
    exit();
} else {
  phpinfo();
}
?>