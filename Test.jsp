using System;
using System.Linq;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace ConsoleApp1
{
    class Program
    {
        static void Main(string[] args)
        {
            //Console.WriteLine("Hello World!");
            string url = "http://files.olo.com/pizzas.json";
            string contents;
            using (var wc = new System.Net.WebClient())
                contents = wc.DownloadString(url);

            if (!string.IsNullOrEmpty(contents))
            {
                try
                {
                    List<Pizza> pizzas = JsonConvert.DeserializeObject<List<Pizza>>(contents);
                    if (pizzas == null)
                        throw new Exception("List is null");
                    if (pizzas != null && pizzas.Count == 0)
                        throw new Exception("List is empty");

                    IList<PizzaRank> rank = new List<PizzaRank>();
                    foreach (Pizza pizza in pizzas)
                    {
                        if (pizza != null && pizza.toppings != null && pizza.toppings.Count > 0)
                        {
                            var pizzarank = rank.FirstOrDefault(x => x.toppings.SequenceEqual(pizza.toppings));
                            if (pizzarank == null)
                                rank.Add(new PizzaRank { Orders = 1, toppings = pizza.toppings });
                            else
                                pizzarank.Orders = pizzarank.Orders + 1;
                        }
                    }

                    var result = rank.OrderByDescending(n => n.Orders).ToArray();
                    int i = 1;
                    foreach (PizzaRank prank in result)
                    {
                        if (i > 20)
                            break;
                        var topps = String.Join(", ", prank.toppings.ToArray());
                        Console.Write(string.Format("Rank {0}, Orders {1}, toppings {2}\r\n", i.ToString(), prank.Orders.ToString(), topps.ToString()));
                        i++;
                    }

                }
                catch(Exception ex)
                {
                    Console.Write(string.Format("Cannot convert json file into list of pizzas {0}", ex.Message));
                }
            }

        }
        public class Pizza
        {
            public IList<string> toppings { get; set; }
        }

        public class PizzaRank
        {
            public int Orders { get; set; }
            public IList<string> toppings { get; set; }
        }
    }


}
