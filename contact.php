<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// configure
$from = 'Demo contact form <demo@domain.com>';
$sendTo = 'Test contact form <Mukelathegreat@gmail.com>'; // Add Your Email
$subject = 'New message from contact form';
$fields = array('name' => 'Name', 'subject' => 'Subject', 'email' => 'Email', 'message' => 'Message'); // array variable name => Text to appear in the email
$okMessage = 'Contact form successfully submitted. Thank you, I will get back to you soon!';
$errorMessage = 'There was an error while submitting the form. Please try again later';

try
{
    $emailText = "You have new message from contact form\n=============================\n";

    // Validate and sanitize each field
    foreach ($_POST as $key => $value) {
        if (isset($fields[$key])) {
            $value = strip_tags(trim($value)); // Basic sanitation
            $emailText .= "$fields[$key]: $value\n";
        }
    }

    $headers = array(
        'Content-Type: text/plain; charset="UTF-8";',
        'From: ' . $from,
        'Reply-To: ' . $from,
        'Return-Path: ' . $from,
    );
    
    // Send the email
    if (mail($sendTo, $subject, $emailText, implode("\n", $headers))) {
        $responseArray = array('type' => 'success', 'message' => $okMessage);
    } else {
        throw new Exception('Failed to send email.');
    }
}
catch (Exception $e)
{
    $responseArray = array('type' => 'danger', 'message' => $errorMessage . ' ' . $e->getMessage());
}

if (!empty($_SERVER['HTTP_X_REQUESTED_WITH']) && strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest') {
    $encoded = json_encode($responseArray);

    header('Content-Type: application/json');

    echo $encoded;
}
else {
    echo $responseArray['message'];
}

?>
