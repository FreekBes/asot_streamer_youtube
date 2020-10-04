<?PHP
	echo PHP_EOL;
	$asotUrl = "https://www.astateoftrance.com/episodes/episode-" . trim($argv[1]) . "/";
	echo $asotUrl, PHP_EOL;
	$asotPage = file_get_contents($asotUrl);
	$asotPage = substr($asotPage, strrpos($asotPage, "<html"));
	$epContent = "No tracklist available for this episode";
	$doc = new DOMDocument();
	@$doc->loadHTML($asotPage);
	$main = $doc->getElementById("main");
	if (!empty($main)) {
		try {
			$epContent = $main->getElementsByTagName("h1")->item(0)->nextSibling->textContent;
			$epContent .= PHP_EOL . PHP_EOL;
			$tracklist = $main->getElementsByTagName("ol");
			if ($tracklist->length > 0) {
				$tracklist = $tracklist->item(0);
				$tracklistItems = $tracklist->getElementsByTagName("li");
				for ($i = 0; $i < $tracklistItems->length; $i++) {
					$epContent .= ($i+1) . ". " . strip_tags(str_replace("<br>", PHP_EOL, $tracklistItems[$i]->saveHTML())) . PHP_EOL;
				}
			}
			else {
				$epContent .= $main->getElementsByTagName("article")->item(0)->textContent;
			}
		}
		catch(Exception $e) {
			echo "Something went wrong: ".$e->getMessage(), PHP_EOL;
		}
	}
	else {
		echo "Main not found", PHP_EOL;
	}
	file_put_contents("asotdata.txt", $epContent);
?>