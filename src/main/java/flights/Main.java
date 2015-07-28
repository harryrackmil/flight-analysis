/*
 * Copyright (c) 2007-2015 Concurrent, Inc. All Rights Reserved.
 *
 * Project and contact information: http://www.cascading.org/
 *
 * This file is part of the Cascading project.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package flights;

import java.util.Properties;

import cascading.flow.Flow;
import cascading.flow.FlowConnector;
import cascading.flow.FlowDef;
import cascading.flow.hadoop2.Hadoop2MR1FlowConnector;
import cascading.operation.aggregator.Count;
import cascading.operation.regex.RegexSplitGenerator;
import cascading.operation.Debug;
import cascading.operation.DebugLevel;
import cascading.pipe.Each;
import cascading.pipe.Every;
import cascading.pipe.GroupBy;
import cascading.pipe.Pipe;
import cascading.pipe.assembly.Retain;
import cascading.property.AppProps;
import cascading.scheme.hadoop.TextDelimited;
import cascading.tap.Tap;
import cascading.tap.hadoop.Hfs;
import cascading.tuple.Fields;


public class Main
  {
  public static void main( String[] args )
    {
    String inPath = args[ 0 ];
    String yearPath = args[ 1 ];
    String monthPath = args[ 2 ];
    String weekdayPath = args[ 3 ];


    Properties properties = new Properties();
    AppProps.setApplicationJarClass( properties, Main.class );
    FlowConnector flowConnector = new Hadoop2MR1FlowConnector( properties );

    // create source and sink taps
    Tap inTap = new Hfs( new TextDelimited( true, "," ), inPath );
    Tap yearTap = new Hfs( new TextDelimited( true, "," ), yearPath );
    Tap monthTap = new Hfs( new TextDelimited(true, ","), monthPath );
    Tap weekdayTap = new Hfs( new TextDelimited(true, ","), weekdayPath );
    
    Fields cityTime = new Fields("Dest", "Year", "Month", "DayOfWeek");
    Pipe inPipe = new Pipe("flightsPipe");
    inPipe = new Retain( inPipe, cityTime );

    // determine the word counts
    Pipe yearPipe = new Pipe( "yearPipe", inPipe );
    Fields cityYear = new Fields("Dest", "Year");
    yearPipe = new Retain( yearPipe, cityYear );
    yearPipe = new GroupBy( yearPipe, cityYear );
    yearPipe = new Every( yearPipe, Fields.ALL, new Count(), Fields.ALL );
    //yearPipe = new Each( yearPipe, DebugLevel.VERBOSE, new Debug( true ) );


    Pipe monthPipe = new Pipe( "monthPipe", inPipe );
    Fields cityMonth = new Fields("Dest", "Month");
    monthPipe = new Retain( monthPipe, cityMonth );
    monthPipe = new GroupBy( monthPipe, cityMonth );
    monthPipe = new Every( monthPipe, Fields.ALL, new Count(), Fields.ALL );
    //monthPipe = new Each( monthPipe, DebugLevel.VERBOSE, new Debug( true ) );

    Pipe weekdayPipe = new Pipe( "weekdayPipe", inPipe );
    Fields cityWeekday = new Fields("Dest", "DayOfWeek");
    weekdayPipe = new Retain( weekdayPipe, cityWeekday );
    weekdayPipe = new GroupBy( weekdayPipe, cityWeekday );
    weekdayPipe = new Every( weekdayPipe, Fields.ALL, new Count(), Fields.ALL );
    //weekdayPipe = new Each( weekdayPipe, DebugLevel.VERBOSE, new Debug( true ) );


    // connect the taps, pipes, etc., into a flow
    FlowDef flowDef = FlowDef.flowDef().setName( "flights" ).addSource( inPipe, inTap ).addTailSink( yearPipe, yearTap ).addTailSink( monthPipe, monthTap ).addTailSink( weekdayPipe, weekdayTap );

    // write a DOT file and run the flow
    Flow flightFlow = flowConnector.connect( flowDef );
    //wcFlow.writeDOT( "dot/wc.dot" );
    flightFlow.complete();
    }
  }
