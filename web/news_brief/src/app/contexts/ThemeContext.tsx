"use client";
import { createContext, ReactNode, useState } from "react";

interface ThemeContextType {
  theme: string;
  setTheme: (theme: string) => void;
}

interface Props {
  children: ReactNode;
}
export const ThemeContext = createContext<ThemeContextType | undefined>(undefined);
const ThemeProvider = ({ children }: Props) => {
  const [theme, setTheme] = useState("light");
  return(
    <ThemeContext.Provider value ={{theme,setTheme}}>
        <div className={theme==="light"? "light-mode":"dark-mode"}>
            {children}
        </div>
    </ThemeContext.Provider>
  )
};
export default ThemeProvider
