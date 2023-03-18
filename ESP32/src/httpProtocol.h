#ifndef _HTTP_PROTOCOL
#define _HTTP_PROTOCOL

#include <HTTPClient.h>

String httpGETRequest(String serverName);
String httpPOSTRequest(String serverName, String param);

#endif