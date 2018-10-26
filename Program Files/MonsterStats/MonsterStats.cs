using System;
using System.Data.SqlClient;
using System.Configuration;
using System.Data;

namespace MonsterStats
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                using (SqlConnection conn = new SqlConnection(ConfigurationManager.ConnectionStrings["conn"].ConnectionString))
                {
                    conn.Open();

                    Console.Write("Please enter a monster name:");
                    string name = Console.ReadLine();

                    SqlCommand dataCommand = new SqlCommand();
                    dataCommand.Connection = conn;
                    dataCommand.CommandType = CommandType.Text;
                    dataCommand.CommandText =
                        "Select Name, Str,Dex,Con,Wis,Int,Cha " +
                        "from MonsterAllView (nolock) where Name = @Name";

                    SqlParameter param = new SqlParameter("@Name", SqlDbType.VarChar, 50);
                    param.Value = name;
                    dataCommand.Parameters.Add(param);
                    Console.WriteLine("Finding monster stats for {0}\n\n", name);
                    SqlDataReader dataReader = dataCommand.ExecuteReader();
                    if (!dataReader.HasRows)
                        Console.WriteLine("No monster by the name of {0}", name);
                    else
                    {
                        while (dataReader.Read())
                        {
                            string name1 = dataReader.GetString(0);
                             int Str = dataReader.GetInt32(1);
                             int Dex = dataReader.GetInt32(2);
                             int Con = dataReader.GetInt32(3);
                             int Wis = dataReader.GetInt32(4);
                             int Int = dataReader.GetInt32(5);
                             int Cha = dataReader.GetInt32(6);

                             String Str1 = Str.ToString();
                             String Dex1 = Dex.ToString();
                             String Con1 = Con.ToString();
                             String Wis1 = Wis.ToString();
                             String Int1 = Int.ToString();
                             String Cha1 = Cha.ToString();

                            Console.WriteLine("Name:{0} Str:{1} Dex:{2} Con:{3} Wis:{4} Int:{5} Cha:{6}", name, Str1, Dex1, Con1, Wis1, Int1, Cha1);

                        }
                    }
                }
            }



            catch (SqlException e)
            {
                Console.WriteLine("Error accessing the database: {0}", e.Message);
            }
            catch (Exception e)
            {
                Console.WriteLine("Something really bad happened: {0}", e.Message);
            }
            finally
            {
                Console.WriteLine("dataConnection.Close() was done by using stmt");
            }
        }
    }
}

       

