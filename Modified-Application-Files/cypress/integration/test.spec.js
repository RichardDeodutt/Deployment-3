describe('Heading', () => {
    it('has the right title', () => {
        cy.visit('http://url-shortener-dev.ap-northeast-1.elasticbeanstalk.com/')

        cy.get('title')
            .invoke('text')
            .should("equal", "URL Shortener")
    });

});