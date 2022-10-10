#Import the application to test
from application import app

#Test the 404 page by requesting a non existing page
def test_fourofour_page():
    #Request the page using get and save the response as a variable
    response = app.test_client().get('/none/fourofour.none')
    #Check if the returned response is a satus code 404 meaning missing page that it should be
    assert response.status_code == 404

#Test the redirect function of the url shortener to a 3rd party webpage
def test_go_page():
    #Request the page using get and save the response as a variable
    response = app.test_client().get('/go')
    #Check if the returned response is a satus code 302 meaning temporarily moved that it should be
    assert response.status_code == 302
    #Check if the redirect page leads to 'http://google.com' that it should be
    assert response.location == 'http://google.com'

#Test the redirect function of the url shortener to a self hosted image file
def test_house_page():
    #Request the page using get and save the response as a variable
    response = app.test_client().get('/house')
    #Check if the returned response is a satus code 302 meaning temporarily moved that it should be
    assert response.status_code == 302
    #Check if the redirect page contains 'house67_Cherry_Lane.jpg' which is the file name that it should be
    assert 'house67_Cherry_Lane.jpg' in response.location

#Test the api page api json
def test_api_page():
    #Request the page using get and save the response as a variable
    response = app.test_client().get('/api')
    #Check if the returned response is a satus code 200 meaning okay that it should be
    assert response.status_code == 200