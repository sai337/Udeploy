












groovy -cp udclient.jar ListAllApplications.groovy https://hostname:8443 username password

the above is the command.

import org.apache.http.HttpRequest;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.auth.AuthScope;
import org.apache.http.auth.UsernamePasswordCredentials;
import org.apache.http.client.CredentialsProvider;
import org.apache.http.client.HttpClient;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.conn.ssl.SSLConnectionSocketFactory;
import org.apache.http.conn.ssl.SSLContextBuilder;
import org.apache.http.conn.ssl.TrustSelfSignedStrategy;
import org.apache.http.impl.client.BasicCredentialsProvider;
import com.urbancode.commons.httpcomponentsutil.HttpClientBuilder;
import groovy.json.JsonSlurper;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.lang.System;
import java.net.URLEncoder;
import org.apache.commons.lang.StringUtils;

class Credentials{
    String serverURL;
        String username;
	    String password;

	    }
	        //sets the values of the Credentials class which contains the server url and the username/password
		    void initializeParameters(Credentials credentials){
		            //if the user provided the input parameters, we're running on the command line
			            if (args.size()==3){

					                credentials.serverURL = args[0];`i
							            credentials.username = args[1];
								                credentials.password = args[2];
										        }
											    }
											        //Initializes an HttpClient that accepts all certificates
												    HttpClient initializeClient(String username,String password){
												            HttpClientBuilder builder = new HttpClientBuilder();
													            builder.setPreemptiveAuthentication(true);
														            builder.setUsername(username);
															            builder.setPassword(password);
																            //Accept all certificates
																	            builder.setTrustAllCerts(true);
																		            //use proxy if defined
																			            if (!StringUtils.isEmpty(System.getenv("PROXY_HOST")) &&
																					                StringUtils.isNumeric(System.getenv("PROXY_PORT")))
																				            {
																						                builder.setProxyHost(System.getenv("PROXY_HOST"));
																								            builder.setProxyPort(Integer.valueOf(System.getenv("PROXY_PORT")));
																									            }

																										            if (!StringUtils.isEmpty(System.getenv("PROXY_USERNAME")) &&
																												                !StringUtils.isEmpty(System.getenv("PROXY_PASSWORD")))
																											            {
																													                builder.setProxyUsername(System.getenv("PROXY_USERNAME"));
																															            builder.setProxyPassword(System.getenv("PROXY_PASSWORD"));
																																            }

																																	            return builder.buildClient();
																																		        }
																																			    //returns a JSON Array that contains a JSON Object for each Application
																																			        Object getApplications(HttpClient client, String serverURL){
																																				        //prepare the GET call to the REST endpoint /cli/application
																																					        applications=performGetRequest(client,serverURL+"/cli/application" )
																																						        return applications;
																																							    }

																																							        //Perform a given HttpRequest, assume answer is <= 299 , parse the outcome as JSON. Also release the connection for the Request.
																																								    Object performGetRequest(HttpClient client, String requestURL){
																																								            HttpRequest request = new HttpGet(requestURL);
																																									            //Execute the REST GET call
																																										            HttpResponse response = client.execute(request);
																																											            //Check that the call was successful
																																												            int statusCode = response.getStatusLine().getStatusCode();
																																													            if ( statusCode > 299 ) {
																																															                println "ERROR : HttpGet to: "+requestURL+ " returned: " +statusCode;
																																																	            return null;
																																																		                }
																																																				        else{
																																																						            //Convert the InputStream returned by response.getEntity().getContent() to a String
																																																							                BufferedReader reader=new BufferedReader(new InputStreamReader(response.getEntity().getContent(),"UTF-8"));
																																																									            StringBuilder builder=new StringBuilder();
																																																										                for(String line=null;(line=reader.readLine())!=null;){
																																																													                   builder.append(line).append("\n");
																																																															               }
																																																																                   JsonSlurper slurper = new JsonSlurper();
																																																																		               objects=slurper.parseText(builder.toString());
																																																																			                   //Ensure to release the connection
																																																																					               request.releaseConnection();
																																																																						                   return objects;
																																																																								           }
																																																																									       }

																																																																									           //Main script contents
																																																																										       Credentials credentials = new Credentials();
																																																																										           initializeParameters(credentials);
																																																																											       HttpClient client = initializeClient(credentials.username,credentials.password);
																																																																											           def applications = getApplications(client,credentials.serverURL);
																																																																												       println "Applications:\n"
																																																																												           if (applications){
																																																																														           applications.each{
																																																																															           println "Name: "+it.name;
																																																																																           println "Description: "+it.description;
																																																																																	           println "Tags: ";
																																																																																		           it.tags.each{
																																																																																			               println "      "+it.name;
																																																																																				               }
																																																																																					               println ""
																																																																																						               }
																																																																																							           }







