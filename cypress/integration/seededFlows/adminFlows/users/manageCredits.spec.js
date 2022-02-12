// More on roles, https://admin.forem.com/docs/forem-basics/user-roles
function openCreditsModal() {
  cy.getModal().should('not.exist');
  cy.findByRole('button', { name: 'Adjust balance' }).click();

  return cy.getModal();
}

function closeUserUpdatedMessage(message) {
  cy.findByText(message).should('exist');
  cy.findByRole('button', { name: 'Close' }).click();
  cy.findByText(message).should('not.exist');
}

describe('Manage User Credits', () => {
  describe('As an admin', () => {
    beforeEach(() => {
      10;
      cy.testSetup();
      cy.fixture('users/adminUser.json').as('user');
      cy.get('@user').then((user) => {
        cy.loginAndVisit(user, '/admin/users/8');
      });
    });

    it('should add credits', () => {
      cy.findByTestId('user-credits').should('have.text', '100');

      openCreditsModal().within(() => {
        cy.findByRole('combobox', { name: 'Adjust balance' }).select('Add');
        cy.findByRole('spinbutton', {
          name: 'Amount of credits to add or remove',
        }).type('10');
        cy.findByRole('textbox', {
          name: 'Why are you adjusting credits?',
        }).type('some reason');
        cy.findByRole('button', { name: 'Adjust' }).click();
      });

      cy.getModal().should('not.exist');
      closeUserUpdatedMessage('Credits have been added!');
      cy.findByTestId('user-credits').should('have.text', '210');
    });

    it('should remove credits', () => {
      cy.findByTestId('user-credits').should('have.text', '100');

      openCreditsModal().within(() => {
        cy.findByRole('combobox', { name: 'Adjust balance' }).select('Remove');
        cy.findByRole('spinbutton', {
          name: 'Amount of credits to add or remove',
        }).type('1');
        cy.findByRole('textbox', {
          name: 'Why are you adjusting credits?',
        }).type('some reason');
        cy.findByRole('button', { name: 'Adjust' }).click();
      });

      cy.getModal().should('not.exist');
      closeUserUpdatedMessage('Credits have been removed.');
      cy.findByTestId('user-credits').should('have.text', '89');
    });

    it('should not remove more credits than a user has', () => {
      cy.findByTestId('user-credits').should('have.text', '100');

      openCreditsModal().within(() => {
        cy.findByRole('combobox', { name: 'Adjust balance' }).select('Remove');
        cy.findByRole('spinbutton', {
          name: 'Amount of credits to add or remove',
        }).type('10');
        cy.findByRole('textbox', {
          name: 'Why are you adjusting credits?',
        }).type('some reason');
        cy.findByRole('button', { name: 'Adjust' }).click();
      });

      cy.getModal().should('not.exist');
      closeUserUpdatedMessage('Credits have been removed.');
      cy.findByTestId('user-credits').should('have.text', '0');
    });
  });
});
