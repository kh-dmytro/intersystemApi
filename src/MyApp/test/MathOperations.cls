
Class MyApp.MathOperations
{
    ClassMethod Add(a As %Integer, b As %Integer) As %Integer
    {
        Quit a + b
    }

    ClassMethod Subtract(a As %Integer, b As %Integer) As %Integer
    {
        Quit a - b
    }

    ClassMethod Multiply(a As %Integer, b As %Integer) As %Integer
    {
        Quit a * b
    }

    ClassMethod Divide(a As %Integer, b As %Integer) As %Float
    {
        If b = 0 {
            Write "Error: Division by zero", !
            Quit ""
        }
        Quit a / b
    }

    ClassMethod Main()
    {
        // Example input
        Set a = 10
        Set b = 5

        // Perform operations
        Set sum = ..Add(a, b)
        Set difference = ..Subtract(a, b)
        Set product = ..Multiply(a, b)
        Set quotient = ..Divide(a, b)

        // Output results
        Write "Sum: ", sum, !
        Write "Difference: ", difference, !
        Write "Product: ", product, !
        If quotient '= "" {
            Write "Quotient: ", quotient, !
        } Else {
            Write "Quotient: Error", !
        }
    }
}
